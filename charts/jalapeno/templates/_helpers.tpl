{{/*
Expand the name of the chart.
*/}}
{{- define "jalapeno.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "jalapeno.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jalapeno.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "jalapeno.labels" -}}
helm.sh/chart: {{ include "jalapeno.chart" . }}
{{ include "jalapeno.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: jalapeno
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "jalapeno.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jalapeno.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Kafka server endpoint for inter-component communication.
*/}}
{{- define "jalapeno.kafkaServer" -}}
{{- .Values.global.kafka.server -}}
{{- end }}

{{/*
ArangoDB server endpoint.
*/}}
{{- define "jalapeno.arangoServer" -}}
{{- .Values.global.arangodb.server -}}
{{- end }}

{{/*
ArangoDB database name.
*/}}
{{- define "jalapeno.arangoDatabase" -}}
{{- .Values.global.arangodb.databaseName -}}
{{- end }}

{{/*
Compute the parent chart's fullname from any context (parent or subchart).
Subcharts have a different .Chart.Name, so they can't use jalapeno.fullname
to reference parent-created resources. This helper hardcodes the parent chart
name "jalapeno" to produce a consistent result everywhere.
*/}}
{{- define "jalapeno.parentFullname" -}}
{{- if contains "jalapeno" .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-jalapeno" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Name of the shared credentials secret.
*/}}
{{- define "jalapeno.credentialsSecret" -}}
{{- include "jalapeno.parentFullname" . }}
{{- end }}

{{/*
Image pull policy from global config.
*/}}
{{- define "jalapeno.imagePullPolicy" -}}
{{- .Values.global.imagePullPolicy | default "Always" -}}
{{- end }}
