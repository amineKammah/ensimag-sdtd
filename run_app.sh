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

sleep 20

# Create spark
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm install spark spark-operator/spark-operator --namespace default
kubectl apply -f data_processing/yaml_files/spark_helm.yaml

wait_for_pending_pods

# Run Demo app
kubectl create -f demo_app/yaml_files/flask-deployment.yaml

wait_for_pending_pods

# Adding auto-scalers
kubectl autoscale deployment.apps/demo-app --min=1 --max=3 --cpu-percent=80
kubectl autoscale deployment.apps/kafka1 --min=1 --max=3 --cpu-percent=80
kubectl autoscale deployment.apps/kafka2 --min=1 --max=3 --cpu-percent=80
kubectl autoscale deployment.apps/zookeeper1 --min=1 --max=3 --cpu-percent=80
kubectl autoscale deployment.apps/zookeeper2 --min=1 --max=3 --cpu-percent=80

# wait_for_external_ip_address

demo_app_link=$(kubectl get service/demo-app-service --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Open $demo_app_link:8080 to access the demo app, you may want to give it a minute to make sure everything has already started"
touch adress_ip.txt
chmod 777 adress_ip.txt
echo "$demo_app_link:8080" > adress_ip.txt
