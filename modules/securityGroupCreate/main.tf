resource "aws_security_group" "application" {
  name        = "application"
  description = "Allow access to application"
  vpc_id      = var.vpc_id

  #ingress {
  #description = "HTTPS ingress"
  #from_port   = 443
  #to_port     = 443
  #protocol    = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  #}
  #ingress {
  #description = "HTTP ingress"
  #from_port   = 80
  #to_port     = 80
  #protocol    = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  #}

  ingress {
    description     = "SSH ingress"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.sec_group_id_lb]
  }
  ingress {
    description     = "Application ingress"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.sec_group_id_lb]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sec_group_id" {
  value = aws_security_group.application.id
}

output "sec_group_application" {
  value = aws_security_group.application
  depends_on = [
    aws_security_group.application,
  ]
}