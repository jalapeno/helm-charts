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
helm install swift-falcon charts/jalapeno-tenant \
  --namespace swift-falcon --create-namespace
```

Tenant 2:
```
helm install green charts/jalapeno-tenant \
  --namespace green --create-namespace \
  --set tenant.name=green
```


uninstall
```
helm uninstall swift-falcon -n swift-falcon
helm uninstall green -n green
helm uninstall jalapeno -n jalapeno
kubectl delete namespace jalapeno
kubectl delete namespace swift-falcon
kubectl delete namespace green
kubectl delete pv arangodb arangodb-apps pvzoo pvkafka 2>/dev/null
```
