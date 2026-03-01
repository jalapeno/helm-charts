{{/*
Adjective-noun name generator for Jalapeno tenant naming.

Provides suggested names for Jalapeno multi-tenant deployments.
By convention, the Helm release name is used as the tenant identifier,
which also becomes the Kubernetes namespace and ArangoDB database name.

Suggested tenant names (adjective-noun combinations):
  swift-falcon   bright-mesa    calm-ridge     bold-creek
  keen-pine      warm-cedar     cool-hawk      wild-wolf
  pure-bear      sage-lake      vast-peak      fair-vale
  true-dale      deep-ford      live-glen      glad-moor
  fine-reef      rare-cove      tame-arch      free-dune

Usage:
  helm install swift-falcon charts/jalapeno-tenant \
    --namespace swift-falcon --create-namespace

  helm install bold-creek charts/jalapeno-tenant \
    --namespace bold-creek --create-namespace \
    --set tenant.name=bold-creek
*/}}

{{/*
Resolve the tenant name. Uses .Values.tenant.name if set,
otherwise falls back to the Helm release name.
*/}}
{{- define "jalapeno.tenantName" -}}
{{- default .Release.Name .Values.tenant.name -}}
{{- end }}
