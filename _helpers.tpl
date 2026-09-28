{{/*
Expand the name of the chart.
*/}}
{{- define "hawk-opentelemetry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "hawk-opentelemetry.fullname" -}}
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

{{- define "hawk-opentelemetry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "hawk-opentelemetry.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- required "serviceAccount.name is required" .Values.serviceAccount.name }}
{{- else }}
{{- required "serviceAccount.name is required" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "hawk-opentelemetry.labels" -}}
helm.sh/chart: {{ include "hawk-opentelemetry.chart" . }}
app.kubernetes.io/name: {{ include "hawk-opentelemetry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: hawk-opentelemetry
{{- end }}

{{- define "hawk-opentelemetry.collector.fullname" -}}
{{- printf "%s-collector" (include "hawk-opentelemetry.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "hawk-opentelemetry.collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hawk-opentelemetry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: opentelemetry-collector
{{- end }}

{{- define "hawk-opentelemetry.collector.labels" -}}
{{ include "hawk-opentelemetry.labels" . }}
app.kubernetes.io/component: opentelemetry-collector
{{- end }}

{{- define "hawk-opentelemetry.targetallocator.fullname" -}}
{{- printf "%s-targetallocator" (include "hawk-opentelemetry.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "hawk-opentelemetry.targetallocator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hawk-opentelemetry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: opentelemetry-target-allocator
{{- end }}

{{- define "hawk-opentelemetry.targetallocator.labels" -}}
{{ include "hawk-opentelemetry.labels" . }}
app.kubernetes.io/component: opentelemetry-target-allocator
{{- end }}

{{/*
Fail fast when the chart cannot discover Collector pods or Prometheus CRs.
*/}}
{{- define "hawk-opentelemetry.validate" -}}
{{- if not .Values.allowedNamespaces }}
{{- fail "allowedNamespaces must contain at least one namespace" }}
{{- end }}
{{- if not (has .Release.Namespace .Values.allowedNamespaces) }}
{{- fail (printf "allowedNamespaces must include the release namespace %q so the Target Allocator can discover Collector pods" .Release.Namespace) }}
{{- end }}
{{- end }}
