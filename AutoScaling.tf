// This code is launch configuration
resource "aws_launch_configuration" "My-Terraform-launch-configuration" {
  name   = "Terraform"
  image_id      = data.aws_ami.AMIFOREC2.id
  instance_type = var.instance_type
  key_name = var.key_pair
  user_data = file("${path.module}/appscript.sh")
  associate_public_ip_address = true
  security_groups = [aws_security_group.SG-APP.id]
  iam_instance_profile = data.aws_iam_role.Role.name
  lifecycle {
    create_before_destroy = true
  }
}

//This code is for Auto-Scaling group
resource "aws_autoscaling_group" "My-ASG" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.My-Terraform-launch-configuration.name
  availability_zones   = [data.aws_availability_zones.Avaliable-AZ.names][0]
  #vpc_zone_identifier = []
  min_size             = 1
  max_size             = 3
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  load_balancers = [aws_elb.My-Terraform-LB.name]

  tag {
    key                 = "Name"
    value               = "terraform-ASG"
    propagate_at_launch = true
 
  }
}

// Below code is for ASG-Upsacling policy
resource "aws_autoscaling_policy" "Terraform-ASG-Policy" {
  name                   = "ASG-UpScalingPOLICY"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.My-ASG.name
  policy_type            ="SimpleScaling"

}

resource "aws_cloudwatch_metric_alarm" "CloudwatchforASG" {
  alarm_name          = "Terraform-ASG-UpScaling-Alarm"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.My-ASG.name
  }

  alarm_actions     = [aws_autoscaling_policy.Terraform-ASG-Policy.arn]
}

  
// Below code is for ASG-Desacling policy
resource "aws_autoscaling_policy" "Terraform-ASG-DPolicy" {
  name                   = "ASG-Descaling-POLICY"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.My-ASG.name
  policy_type            ="SimpleScaling"

}

resource "aws_cloudwatch_metric_alarm" "CloudwatchforDASG" {
  alarm_name          = "Terraform-ASG-Descaling-Alarm"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.My-ASG.name
  }

  alarm_actions     = [aws_autoscaling_policy.Terraform-ASG-DPolicy.arn]
}

#For installing stress in linux to check ASG working or not(CPU)
/*
amazon-linux-extras install epel -y
yum install stress -y
stress --cpu 8 --timeout 300
*/
