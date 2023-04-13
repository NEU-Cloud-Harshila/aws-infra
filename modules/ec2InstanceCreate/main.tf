data "aws_ami" "example" {
  most_recent = true
  owners      = ["642376440760"]

  filter {
    name   = "name"
    values = ["csye6225*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.example.id
}

#resource "aws_instance" "app_server" {
# ami                     = data.aws_ami.example.id
#instance_type           = var.instance_type
#key_name                = var.ami_key_pair_name
#security_groups         = ["${var.sec_id}"]
#iam_instance_profile    = var.ec2_profile_name
#disable_api_termination = false

#tags = {
# Name = "EC2-${data.aws_ami.example.id}"
#}

#root_block_device {
# volume_size           = var.volume_size
#volume_type           = var.volume_type
#delete_on_termination = true
#}

#user_data = <<EOF
#!/bin/bash
# cd /home/ec2-user/webapp
#echo DB_HOST="${var.host_name}" > .env
#echo DB_USER="${var.username}" >> .env
#echo DB_PASSWORD="${var.password}" >> .env
#echo DB_NAME="${var.db_name}" >> .env
#echo PORT=${var.app_port} >> .env
#echo BUCKETNAME=${var.s3_bucket} >> .env

#sudo chown -R root:ec2-user /var/log
#sudo chmod -R 770 -R /var/log
#sudo systemctl daemon-reload
#sudo systemctl start webapp.service
#sudo systemctl enable webapp.service  

#sudo ../../../opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
# -a fetch-config \
#-m ec2 \
# -c file:packer/cloudwatch-config.json \
# -s 

#EOF

#subnet_id = var.subnet_ids[0]
#}

resource "aws_launch_template" "app_server" {
  depends_on = [
    var.sec_group_application
  ]
  name          = "launch_configuration"
  image_id      = data.aws_ami.example.id
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${var.sec_id}"]
  }

  tags = {
    Name = "EC2-${data.aws_ami.example.id}"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      kms_key_id  = aws_kms_key.webapp-kms-ec2.arn
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  user_data = base64encode(data.template_file.userData.rendered)
}

resource "aws_autoscaling_group" "app_autoscaling_group" {
  name                = "csye6225-auto-scale-group"
  default_cooldown    = 60
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }
  health_check_type = "EC2"
  tag {
    key                 = "webapp"
    value               = "webappEC2Instance"
    propagate_at_launch = true
  }
  target_group_arns = [var.aws_lb_target_group_arn]
}

resource "aws_autoscaling_policy" "scaleUpPolicy" {
  name                    = "Up policy"
  policy_type             = "SimpleScaling"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.app_autoscaling_group.name
  metric_aggregation_type = "Average"
}

resource "aws_autoscaling_policy" "scaleDownPolicy" {
  name                    = "Down policy"
  policy_type             = "SimpleScaling"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.app_autoscaling_group.name
  metric_aggregation_type = "Average"

}

resource "aws_cloudwatch_metric_alarm" "scaleUpAlarm" {
  alarm_name          = "ASG_Scale_Up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 4
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_autoscaling_group.name
  }
  alarm_description = "Scale up to 4%"
  alarm_actions     = [aws_autoscaling_policy.scaleUpPolicy.arn]
}

resource "aws_cloudwatch_metric_alarm" "scaleDownAlarm" {
  alarm_name          = "ASG_Scale_Down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "cpu usage"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_autoscaling_group.name
  }
  alarm_description = "Scale down to 2%"
  alarm_actions     = [aws_autoscaling_policy.scaleDownPolicy.arn]
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.record_creation_name
  private_zone = false
}

resource "aws_route53_record" "record_creation" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_creation_name
  type    = "A"
  alias {
    evaluate_target_health = true
    name                   = var.application_load_balancer_dns_name
    zone_id                = var.application_load_balancer_zone_id
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "webapp-kms-ec2" {
  description              = " Encryption key for instance"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  policy = jsonencode({
    "Id" : "key-consolepolicy-3",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}