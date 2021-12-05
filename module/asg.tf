# Create Security Group for ec2 instances
resource "aws_security_group" "ec2_security_group" {
  name        = "idea11-ci-demo-ec2-sg"
  description = "Security Group for Idea 11 CI Demo ec2 servers"
  vpc_id      = aws_vpc.demo_vpc.id

  # Allow Ingress Traffic HTTP
  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.alb_security_group.id]
    description     = "Allow all HTTP Traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all Outbound Traffic"
  }

  tags = {
    Name      = "idea11-ci-demo-ec2-sg"
    Terraform = "True"
  }
}

# Create launch Configuration
resource "aws_launch_configuration" "demo_launch_config" {
  name_prefix                 = "idea11-ci-demo-asg-launch-config-"
  image_id                    = data.aws_ssm_parameter.ssm_amazon_linux_ami.value
  iam_instance_profile        = aws_iam_instance_profile.ec2_demo_instance_profile.name
  instance_type               = "t3a.nano"
  security_groups             = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = false

  user_data = file("${path.module}/provisioning/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaling group to maintain server avalibility and uptime
resource "aws_autoscaling_group" "idea11_demo_asg_group" {
  name                 = "idea11-ci-demo-asg-group"
  launch_configuration = aws_launch_configuration.demo_launch_config.name

  max_size          = 6
  min_size          = 3
  desired_capacity  = 3
  health_check_type = "EC2"

  target_group_arns = [
    aws_lb_target_group.external_alb_tg.arn
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [
    aws_subnet.private_subnet_aza.id,
    aws_subnet.private_subnet_azb.id,
    aws_subnet.private_subnet_azc.id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ASG Scale-up Policy
resource "aws_autoscaling_policy" "demo_web_asg_policy_up" {
  name                   = "demo_web_asg_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.idea11_demo_asg_group.name
}

resource "aws_cloudwatch_metric_alarm" "demo_web_asg_cpu_alarm_up" {
  alarm_name          = "demo_web_asg_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.idea11_demo_asg_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.demo_web_asg_policy_up.arn]
}

#ASG Scale-down Policy

resource "aws_autoscaling_policy" "demo_web_asg_policy_down" {
  name                   = "devops_web_asg_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.idea11_demo_asg_group.name
}

resource "aws_cloudwatch_metric_alarm" "demo_web_asg_cpu_alarm_down" {
  alarm_name          = "devops_web__asg_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.idea11_demo_asg_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.demo_web_asg_policy_down.arn]
}

