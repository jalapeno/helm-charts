{{/*
Resolve the tenant name. Uses .Values.tenant.name if set,
otherwise falls back to the Helm release name.
*/}}
{{- define "tenant.name" -}}
{{- default .Release.Name .Values.tenant.name -}}
{{- end }}

{{/*
Resolve the per-tenant ArangoDB database name.
Uses global.arangodb.databaseName if explicitly set,
otherwise falls back to the tenant name.
*/}}
{{- define "tenant.databaseName" -}}
{{- if .Values.global.arangodb.databaseName -}}
{{- .Values.global.arangodb.databaseName -}}
{{- else -}}
{{- include "tenant.name" . -}}
{{- end -}}
{{- end }}

{{/*
Name of the credentials secret for this tenant.
*/}}
{{- define "tenant.credentialsSecret" -}}
{{- printf "%s-credentials" (include "tenant.name" .) -}}
{{- end }}

{{/*
Common labels for tenant resources.
*/}}
{{- define "tenant.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: jalapeno
jalapeno.io/tenant: {{ include "tenant.name" . }}
{{- end }}

{{/*
Adjective-noun name suggestions for tenants.

Suggested tenant names (adjective-noun combinations):
  swift-falcon   bright-mesa    calm-ridge     bold-creek
  keen-pine      warm-cedar     cool-hawk      wild-wolf
  pure-bear      sage-lake      vast-peak      fair-vale
  true-dale      deep-ford      live-glen      glad-moor
  fine-reef      rare-cove      tame-arch      free-dune
*/}}
