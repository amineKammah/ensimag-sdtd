#!/bin/bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
chmod +x run_app.sh
chmod +x destroy_app.sh
./run_app.sh
