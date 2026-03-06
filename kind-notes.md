# Install Kind
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

# Install kubectl if not already present
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
```

# Create a cluster with port mappings for Jalapeno NodePort services
```
cat <<EOF | kind create cluster --name jalapeno --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30852
    hostPort: 30852
    protocol: TCP
  - containerPort: 30800
    hostPort: 30800
    protocol: TCP
  - containerPort: 30700
    hostPort: 30700
    protocol: TCP
  - containerPort: 30511
    hostPort: 30511
    protocol: TCP
  - containerPort: 30092
    hostPort: 30092
    protocol: TCP
EOF
```
# Verify
```
kubectl cluster-info --context kind-jalapeno
kubectl get nodes
```

Install jalapeno
```
helm install jalapeno oci://ghcr.io/jalapeno/helm-charts/jalapeno \
  --version 1.1.0 \
  --namespace jalapeno --create-namespace \
  --set arangodb.persistence.data.storageClass=standard \
  --set arangodb.persistence.appdata.storageClass=standard \
  --set kafka.zookeeper.persistence.storageClass=standard \
  --set kafka.broker.persistence.storageClass=standard
```