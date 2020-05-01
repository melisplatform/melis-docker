
# Create namespace 
```bash
kubectl create namespace melis
```
# Create mysql secret
```bash
kubectl create secret generic mysql-addon-db --from-literal=host=melis-db --from-literal=password=c@ll1c0d3r  --from-literal=user=root  --from-literal=db=melisplatform
```
# Deploy app into cluster
```bash
kubectl apply -f k8s/
``` 
# View deployments 
```bash
kubectl get all -n melis
```