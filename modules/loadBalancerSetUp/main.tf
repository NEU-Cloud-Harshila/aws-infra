resource "aws_lb" "application_load_balancer" {
  name                       = "app-load-balancer-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.loadbalancer_sg.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "webapp-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = var.app_port

  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}