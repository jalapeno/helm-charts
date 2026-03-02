Delete everything when running thru testing:

```
helm uninstall jalapeno -n jalapeno
kubectl delete namespace jalapeno
kubectl delete pv arangodb arangodb-apps pvzoo pvkafka 2>/dev/null
```

Install topology only
```
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-topology-only.yaml \
  --namespace jalapeno --create-namespace \
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

### Install multi-tenant

Base:
```
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-multi-tenant-infra.yaml \
  --namespace jalapeno --create-namespace \
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

Tenant 1:
```
helm install poblano charts/jalapeno-tenant \
  --namespace poblano --create-namespace
  --set tenant.name=poblano
```

Tenant 2:
```
helm install serrano charts/jalapeno-tenant \
  --namespace serrano --create-namespace \
  --set tenant.name=serrano
```


uninstall
```
helm uninstall poblano -n poblano
helm uninstall serrano -n serrano
helm uninstall jalapeno -n jalapeno
kubectl delete namespace jalapeno
kubectl delete namespace poblano
kubectl delete namespace serrano
kubectl delete pv arangodb arangodb-apps pvzoo pvkafka 2>/dev/null
```

Build packages
```
cd helm-charts && rm -f charts/jalapeno/Chart.lock && helm dependency build charts/jalapeno 2>&1 && echo "---" && helm package charts/jalapeno 2>&1 && helm package charts/jalapeno-tenant 2>&1
```

publish/push charts
```
cd ~/helm-charts
```

# Login to ghcr.io (use your GitHub username and PAT as password)
```
echo YOUR_GITHUB_PAT | helm registry login ghcr.io --username YOUR_GITHUB_USERNAME --password-stdin
```

# Push both charts
```
helm push jalapeno-0.1.0.tgz oci://ghcr.io/jalapeno/helm-charts
helm push jalapeno-tenant-0.1.0.tgz oci://ghcr.io/jalapeno/helm-charts
```

# Verify they're published
```
helm show chart oci://ghcr.io/jalapeno/helm-charts/jalapeno --version 0.1.0
helm show chart oci://ghcr.io/jalapeno/helm-charts/jalapeno-tenant --version 0.1.0
```

Install topology-only
```
helm install jalapeno oci://ghcr.io/jalapeno/helm-charts/jalapeno \
  --version 0.1.0 \
  --namespace jalapeno --create-namespace \
  --set telegraf-ingress.enabled=false \
  --set telegraf-egress.enabled=false \
  --set influxdb.enabled=false \
  --set grafana.enabled=false \
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

Install base
```
helm install jalapeno oci://ghcr.io/jalapeno/helm-charts/jalapeno \
  --version 0.1.0 \
  --namespace jalapeno --create-namespace \
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

Install tenant
```
helm install swift-falcon oci://ghcr.io/jalapeno/helm-charts/jalapeno-tenant \
  --version 0.1.0 \
  --namespace swift-falcon --create-namespace
```