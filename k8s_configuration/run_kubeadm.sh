#!/bin/bash
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  ./~/ensimag-sdtd/run_app.sh