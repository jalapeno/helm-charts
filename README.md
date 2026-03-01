# Jalapeno Helm Charts

Helm charts for deploying [Jalapeno](https://github.com/jalapeno/jalapeno), an infrastructure platform for SDN control plane development.

## Charts

| Chart | Description |
|-------|-------------|
| **jalapeno** | Full platform deployment (collectors, processors, databases, API, UI) |
| **jalapeno-tenant** | Per-tenant deployment for multi-tenant environments |

## Prerequisites

- Kubernetes 1.24+
- Helm 3.10+
- `kubectl` configured to communicate with your cluster

## Quick Start

### Base Installation (all components)

```bash
helm install jalapeno charts/jalapeno \
  --namespace jalapeno --create-namespace
```

### Topology-Only Stack

Deploys only BMP/topology components (GoBMP, Kafka, ArangoDB, graph processors, API) without the telemetry stack (Telegraf, InfluxDB, Grafana).

```bash
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-topology-only.yaml \
  --namespace jalapeno --create-namespace
```

### Kind Cluster

```bash
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-kind.yaml \
  --namespace jalapeno --create-namespace
```

### OpenShift

```bash
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-openshift.yaml \
  --namespace jalapeno --create-namespace
```

## Multi-Tenant Deployment

Multi-tenant mode deploys shared infrastructure (ArangoDB, Kafka, API, UI) in the
`jalapeno` namespace, with per-tenant collectors and processors in isolated namespaces.
Each tenant gets its own ArangoDB database, GoBMP collector, and graph processors.

### Step 1: Deploy shared infrastructure

This installs only ArangoDB, Kafka/Zookeeper, the API, and UI -- no collectors or
processors. Those are deployed per-tenant in step 2.

```bash
helm install jalapeno charts/jalapeno \
  -f charts/jalapeno/values-multi-tenant-infra.yaml \
  --namespace jalapeno --create-namespace
```

> **Note on the API:** The API currently connects to a single ArangoDB database.
> A multi-tenant API refactor is planned to allow querying across tenant databases.
> In the interim, the shared API serves the default `jalapeno` database.

### Step 2: Deploy a tenant

The Helm release name becomes the tenant name (and ArangoDB database name).
Each tenant gets its own GoBMP, GoBMP-Arango, linkstate-edge, igp-graph, and ip-graph
in an isolated namespace, all pointing at the shared Kafka and ArangoDB.

```bash
helm install swift-falcon charts/jalapeno-tenant \
  --namespace swift-falcon --create-namespace
```

Or specify a custom tenant name:

```bash
helm install my-release charts/jalapeno-tenant \
  --namespace my-tenant-ns --create-namespace \
  --set tenant.name=my-tenant
```

#### Suggested tenant names

For memorable, operator-friendly names, use adjective-noun combinations:

```
swift-falcon   bright-mesa    calm-ridge     bold-creek
keen-pine      warm-cedar     cool-hawk      wild-wolf
pure-bear      sage-lake      vast-peak      fair-vale
true-dale      deep-fjord     live-glen      glad-moor
fine-reef      rare-cove      tame-arch      free-dune
```

### Step 3: Deploy additional tenants

```bash
helm install bold-creek charts/jalapeno-tenant \
  --namespace bold-creek --create-namespace

helm install keen-pine charts/jalapeno-tenant \
  --namespace keen-pine --create-namespace
```

## Configuration

### Enabling/Disabling Components

Every component can be toggled via `<component>.enabled`:

```bash
# Enable optional SRv6 Local SIDs processor
helm install jalapeno charts/jalapeno \
  --namespace jalapeno --create-namespace \
  --set srv6-localsids.enabled=true
```

### Customizing Images

```bash
helm install jalapeno charts/jalapeno \
  --namespace jalapeno --create-namespace \
  --set gobmp.image.tag=v2.0.0 \
  --set arangodb.image.tag=3.11.0
```

### Customizing Storage

```bash
helm install jalapeno charts/jalapeno \
  --namespace jalapeno --create-namespace \
  --set arangodb.persistence.data.size=200Gi \
  --set arangodb.persistence.data.storageClass=fast-ssd
```

### Using hostPath Volumes

For bare-metal or single-node clusters:

```bash
helm install jalapeno charts/jalapeno \
  --namespace jalapeno --create-namespace \
  --set arangodb.hostPath.enabled=true \
  --set kafka.zookeeper.hostPath.enabled=true \
  --set kafka.broker.hostPath.enabled=true
```

## Uninstalling

```bash
# Remove the release
helm uninstall jalapeno --namespace jalapeno

# Remove the namespace (also deletes PVCs)
kubectl delete namespace jalapeno

# Remove tenant
helm uninstall swift-falcon --namespace swift-falcon
kubectl delete namespace swift-falcon
```

## Architecture

```
                    Network(s)
                        |
                   BMP / gNMI feeds
                        |
                   +-----------+
                   | Collectors |  (GoBMP, Telegraf-Ingress)
                   +-----------+
                        |
                   +-----------+
                   |   Kafka   |  (message bus)
                   +-----------+
                     /        \
          +-----------+    +-----------+
          | Topology  |    | Telemetry |
          | Processors|    | Processors|
          +-----------+    +-----------+
               |                |
          +-----------+    +-----------+
          | ArangoDB  |    | InfluxDB  |
          | (GraphDB) |    |  (TSDB)   |
          +-----------+    +-----------+
               |                |
          +-----------+    +-----------+
          |    API    |    |  Grafana  |
          +-----------+    +-----------+
               |
          +-----------+
          | SDN Apps  |  (srctl, etc.)
          +-----------+
```

## Adding New Graph Processors

To add a new graph processor:

1. Create a new subchart directory under `charts/jalapeno/charts/<your-processor>/`
2. Add `Chart.yaml`, `values.yaml`, and `templates/deployment.yaml`
3. Follow the pattern of existing processors (e.g., `igp-graph`)
4. Add a corresponding section in the parent `values.yaml` with `enabled: false`
5. For tenant support, add a template in `charts/jalapeno-tenant/templates/`

## License

See [LICENSE](https://github.com/jalapeno/jalapeno/blob/main/LICENSE).
