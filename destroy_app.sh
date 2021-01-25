kubectl delete --all replicationcontrollers --force
kubectl delete --all jobs --force 
kubectl delete --all deployments --force
kubectl delete --all pods --force
kubectl delete --all services --force
kubectl delete --all pvc --force
kubectl delete --all sparkapplication --force
kubectl delete --all hpa --force
helm delete spark
rm adress_ip.txt
