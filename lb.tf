resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.vpc.id

  // commented out the below block as we are using SSL
  # ingress {
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"] # Allow HTTP from anywhere
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Allow HTTPS from anywhere
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Load Balancer Security Group"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_lb" "webapp_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name = "Web Application Load Balancer"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# resource "aws_lb_listener" "webapp_listener" {
#   load_balancer_arn = aws_lb.webapp_lb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_tg.arn
#   }
# }
