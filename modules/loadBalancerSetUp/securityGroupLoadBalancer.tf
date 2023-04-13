resource "aws_security_group" "loadbalancer_sg" {
  name_prefix = "load_balancer_sec_group"
  description = "Allow access to application"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sec_group_id_lb" {
  value = aws_security_group.loadbalancer_sg.id
}