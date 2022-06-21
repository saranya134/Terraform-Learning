
provider "aws" {
  

  region = "ap-south-1"

}
resource "aws_security_group" "instance" {
  

  name = "terraform-sg"   ingress {
    

    from_port   = "0"

    to_port     = "0"

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }
  

  egress {
    

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }
  

}

resource "aws_launch_configuration" "example" {
  

  image_id        = "ami-068257025f72f470d"

  instance_type   = "t2.micro"

  security_groups = [aws_security_group.instance.id]

  associate_public_ip_address = true   user_data     = <<EOF

#!/bin/bash

apt-get update

apt-get install -y apache2

systemctl start apache2

systemctl enable apache2

echo "<h1> Hello bosch</h1>" | sudo tee /var/www/html/index.html

EOF   lifecycle {
  

    create_before_destroy = true

  }
  

}
data "aws_vpc" "default" {
  

  default = true

}
data "aws_subnets" "default" {
  

  filter {
    

    name   = "vpc-id"

    values = [data.aws_vpc.default.id]

  }
  

}
resource "aws_autoscaling_group" "example" {
  

  launch_configuration = aws_launch_configuration.example.name

  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]

  health_check_type = "ELB"   name                 = "asg"

  min_size = 1

  max_size = 2   tag {

    key                 = "Name"

    value               = "terraform-asg-example"

    propagate_at_launch = true
  }
  

} 

resource "aws_lb" "example" {

  name               = "terraform-asg-example"

  load_balancer_type = "application"

  subnets            = data.aws_subnets.default.ids

  security_groups    = [aws_security_group.alb.id]

}
resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.example.arn

  port              = 80

  protocol          = "HTTP"   # By default, return a simple 404 page

  default_action {

    type = "fixed-response"     fixed_response {

      content_type = "text/plain"

      message_body = "404: page not found"

      status_code  = 404

    }

  }

}

resource "aws_security_group" "alb" {

  name = "terraform-example-alb"   # Allow inbound HTTP requests

  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }  # Allow all outbound requests

  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}
resource "aws_lb_target_group" "asg" {

  name     = "terraform-asg-example"

  port     = 80

  protocol = "HTTP"

  vpc_id   = data.aws_vpc.default.id   health_check {

    path                = "/"

    protocol            = "HTTP"

    matcher             = "200"

    interval            = 15

    timeout             = 3

    healthy_threshold   = 2

    unhealthy_threshold = 2

  }

}
resource "aws_lb_listener_rule" "asg" {

  listener_arn = aws_lb_listener.http.arn

  priority     = 100   condition {

    path_pattern {

      values = ["*"]

    }

  }
  action {

    type             = "forward"

    target_group_arn = aws_lb_target_group.asg.arn

  }

}

output "alb_dns_name" {

  value       = aws_lb.example.dns_name

  description = "The domain name of the load balancer"

}

