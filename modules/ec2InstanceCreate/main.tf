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

resource "aws_instance" "app_server" {
  ami                     = data.aws_ami.example.id
  instance_type           = var.instance_type
  key_name                = var.ami_key_pair_name
  security_groups         = ["${var.sec_id}"]
  iam_instance_profile    = var.ec2_profile_name
  disable_api_termination = false

  tags = {
    Name = "EC2-${data.aws_ami.example.id}"
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  user_data = <<EOF
    #!/bin/bash
    cd /home/ec2-user/webapp
    echo DB_HOST="${var.host_name}" > .env
    echo DB_USER="${var.username}" >> .env
    echo DB_PASSWORD="${var.password}" >> .env
    echo DB_NAME="${var.db_name}" >> .env
    echo PORT=${var.app_port} >> .env
    echo BUCKETNAME=${var.s3_bucket} >> .env

    sudo systemctl daemon-reload
    sudo systemctl start webapp.service
    sudo systemctl enable webapp.service 

  EOF

  subnet_id = var.subnet_ids[0]
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.record_creation_name
  private_zone = false
}

resource "aws_route53_record" "record_creation" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_creation_name
  type    = "A"
  ttl     = 60
  records = [aws_instance.app_server.public_ip]
}