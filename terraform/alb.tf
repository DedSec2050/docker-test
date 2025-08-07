resource "aws_lb" "app_alb" {
  name               = "flask-express-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id,
                        aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "flask_tg" {
  name     = "flask-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_target_group" "express_tg" {
  name     = "express-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "default response"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "flask_rule" {
  listener_arn = aws_lb_listener.http.arn

  condition {
    path_pattern {
      values = ["/flask*", "/flask/*"]
    }
  }

  priority = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}

resource "aws_lb_listener_rule" "express_rule" {
  listener_arn = aws_lb_listener.http.arn

  condition {
    path_pattern {
      values = ["/express*", "/express/*"]
    }
  }

  priority = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express_tg.arn
  }
}