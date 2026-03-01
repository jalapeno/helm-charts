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

Install multi-tenant
```
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-multi-tenant-infra.yaml \
  --namespace jalapeno --create-namespace
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

