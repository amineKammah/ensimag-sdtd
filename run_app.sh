function wait_for_pending_pods {
  echo "waiting for pending pods to start..."
  sleep 1
  while test -n "$(kubectl get pods --all-namespaces --field-selector=status.phase=ContainerCreating -o name)"; do
    sleep 3;
  done

  while test -n "$(kubectl get pods --all-namespaces --field-selector=status.phase=Pending -o name)"; do
    sleep 3;
  done
}

function wait_for_external_ip_address {
  echo "waiting for external loadbalancer to be assigned..."
  sleep 1
  while test -z "$(kubectl get service/demo-app-service --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"; do
    sleep 3;
  done
}

# Run Zookeeper and Kafka Service
kubectl create -f messaging_agent/yaml_files/zookeeper-service.yaml
kubectl create -f messaging_agent/yaml_files/zookeeper-cluster.yaml
kubectl create -f messaging_agent/yaml_files/kafka-service.yaml


# Prepare yaml file for kafka deployment
kubectl create -f messaging_agent/yaml_files/kafka-cluster.yaml

wait_for_pending_pods

# Create spark service account
kubectl apply -f data_processing/yaml_files/spark-rbac.yaml

# Prepare yaml file for spark-job
# Getting service IP
K8S_MASTER=$(
  kubectl get node --selector=node-role.kubernetes.io/master \
  -o jsonpath='{$.items[*].status.addresses[?(@.type=="InternalIP")].address}'
)
sub_pattern="s/#K8S_MASTER#/$K8S_MASTER/"
sed "$sub_pattern" data_processing/yaml_files/spark-job.yaml > /tmp/spark-job.yaml
kubectl create -f /tmp/spark-job.yaml

wait_for_pending_pods

# Run Demo app
kubectl create -f demo_app/yaml_files/flask-deployment.yaml

wait_for_pending_pods
# wait_for_external_ip_address

demo_app_link=$(kubectl get service/demo-app-service --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "The app has launched, open $demo_app_link:8080 to access the demo app."