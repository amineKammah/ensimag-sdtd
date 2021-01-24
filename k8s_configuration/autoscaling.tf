# The autoscaling doesn't work in the project because of the problem of kubeadm join in the worker node
# to test this property copy and paste this file at the end of in cluster_config/ec2.tf
# aws launch configuration
resource "aws_launch_configuration" "worker" {
  name_prefix = "worker"
  image_id = lookup(var.amis, var.region)
  instance_type = var.worker_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  iam_instance_profile = "k8s-cluster-iam-worker-profile"
  #user_data = file("./workers_config.sh")
  user_data = <<-EOF
  #!/bin/bash
  # Install kubeadm and Docker
  sudo apt update && sudo apt -y upgrade
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
  sudo apt update
  sudo apt install -y docker-ce kubelet kubeadm kubectl
  export HOME=/root
  echo "hello"
  echo $HOME
  # Configure hostname
  varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
  sudo hostnamectl set-hostname $varHost
  # Run kubeadm
  sleep 10
  git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/${aws_instance.master.private_ip}/;s/#HOSTNAME#/$varHost/"
  sed "$sub_pattern" k8s_configuration/node.yml > ~/node_sdtd.yml
  cat ~/node_sdtd.yml
  sudo kubeadm join --config ~/node_sdtd.yml --v=5
  EOF
  lifecycle {
    create_before_destroy = true
  }
  associate_public_ip_address = true
  
}
resource "aws_autoscaling_group" "worker" {
  name = "${aws_launch_configuration.worker.name}.asg"
  min_size = 1
  desired_capacity = 2 
  max_size = 2
  health_check_type = "ELB"
  launch_configuration = aws_launch_configuration.worker.name
  vpc_zone_identifier       = [aws_subnet.SDTD_VPC_Subnet.id]
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
   tag {
    key = "Name"
    value = "k8s-worker-replace-sdtd" 
    propagate_at_launch = true
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
