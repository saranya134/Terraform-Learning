resource "aws_launch_configuration" "launchconfig" {
  name            = "instance-launch"
  image_id        = "ami-065deacbcaac64cf2"
  instance_type   = "t2.small"
  name_prefix = "testing"
  security_groups = [aws_security_group.securitygroup.id]
  user_data       = file("./appscript.sh")

  lifecycle {
    create_before_destroy = true
  }
}
