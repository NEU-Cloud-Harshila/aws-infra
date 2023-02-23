data "aws_ami" "amzLinux" {
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
  value = data.aws_ami.amzLinux.id
}


resource "aws_instance" "app_server" {
  count = var.subnet_count

  ami             = data.aws_ami.amzLinux.id
  instance_type   = var.instance_type
  key_name        = var.ami_key_pair_name
  security_groups = ["${var.sec_id}"]

  tags = {
    Name = "EC2-${count.index + 1}"
  }

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  subnet_id = var.subnet_ids[count.index]
}