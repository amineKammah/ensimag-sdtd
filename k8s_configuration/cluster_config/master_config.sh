#!/bin/bash

  # Install kubeadm and Docker
  sudo apt update && sudo apt -y upgrade
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
  sudo apt update
  sudo apt install -y docker-ce kubelet kubeadm kubectl

  # Configure hostname
  varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
  sudo hostnamectl set-hostname $varHost
  git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  varMasterIp=$(hostname -I)
  varMaster=$(echo $varMasterIp | cut -d' ' -f1)
  sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/$varMaster/"
  sed "$sub_pattern" k8s_configuration/aws.yml > ~/aws_sdtd.yml
  cat ~/aws_sdtd.yml
  sudo kubeadm init --config ~/aws_sdtd.yml
  # Prepare kubeconfig file for download to local machine
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  chmod +x k8s_configuration/run_kubeadm.sh
  ./k8s_configuration/run_kubeadm.sh
  # Make the master ready
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  chmod +x run_app.sh
  chmod +x destroy_app.sh
  sleep 30
  ./run_app.sh