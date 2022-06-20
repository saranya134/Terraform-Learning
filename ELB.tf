resource "aws_elb" "My-Terraform-LB" {
  name = "LB-FOR-ASG"
  security_groups = [aws_security_group.SG-APP.id]
  availability_zones = toset([data.aws_availability_zones.Avaliable-AZ.names][0])
  cross_zone_load_balancing   = true
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 4
    interval = 5
    target = "HTTP:80/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
}
