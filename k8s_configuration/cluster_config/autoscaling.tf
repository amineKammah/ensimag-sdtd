
# aws launch configuration
resource "aws_launch_configuration" "worker" {
  name_prefix = "worker"
  image_id = lookup(var.amis, var.region)
  instance_type = var.worker_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-worker-profile"
  user_data = file("./workers_config.sh")
  lifecycle {
    create_before_destroy = true
  }
  associate_public_ip_address = true
  
}
resource "aws_autoscaling_group" "worker" {
  name = "${aws_launch_configuration.worker.name}.asg"
  min_size = 1
  desired_capacity = 2 
  max_size = 4
  health_check_type = "ELB"
  launch_configuration = aws_launch_configuration.worker.name

  enabled_metrics = [ 
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
   ]
   metrics_granularity = "1Minute"
   #required to redeploy without an outage
   lifecycle {
     create_before_destroy = true
   }
   tags {
    Name = "k8s-worker-replace-sdtd"
   }
}

resource "aws_autoscaling_policy" "worker_policy_up" {
   name                   = "worker_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.worker.name
}

resource "aws_cloudwatch_metric_alarm" "worker_cpu_alarme_up" {
    alarm_name                = "worker_cpu_alarme_up"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  dimensions = {
  AutoScalingGroupName = aws_autoscaling_group.worker.name
}
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.worker_policy_up.arn]
}

resource "aws_autoscaling_policy" "worker_policy_down" {
  name                   = "worker_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.worker.name
}
resource "aws_cloudwatch_metric_alarm" "worker_cpu_alarme_down" {
    alarm_name                = "worker_cpu_alarme_down"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10"
  dimensions = {
  AutoScalingGroupName = aws_autoscaling_group.worker.name
}
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.worker_policy_down.arn]
}