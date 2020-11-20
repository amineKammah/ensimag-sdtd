kubeadm init --config /etc/kubernetes/aws.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# pour le worker
kubeadm join --config /etc/kubernetes/node.yml

# change to systemd
# create /etc/docker/daemon.json
# Restart the Docker service by running the following command:

systemctl daemon-reload
systemctl restart docker
