{{/*
Expand the name of the chart.
*/}}
{{- define "presto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "presto.fullname" -}}
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
{{- define "presto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "presto.labels" -}}
helm.sh/chart: {{ include "presto.chart" . }}
{{ include "presto.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "presto.selectorLabels" -}}
app.kubernetes.io/name: {{ include "presto.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
define web loadbalancer extra-specs
*/}}
{{- define "service.loadbalancer.extraSpec" -}}
{{- if hasKey . "type" }}{{ fail "field 'type' is not supported in Temporal Helm Chart service.*.spec" }}{{ end }}
{{- if hasKey . "selector" }}{{ fail "field 'selector' is not supported in Temporal Helm Chart service.*.spec" }}{{ end }}
{{- if hasKey . "ports" }}{{ fail "field 'ports' is not supported in Temporal Helm Chart service.*.spec" }}{{ end }}
{{ toYaml . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "presto.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "presto.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define the service account as needed
*/}}
{{- define "presto.serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
serviceAccountName: {{ include "presto.serviceAccountName" . }}
{{- end -}}
{{- end -}}

{{- define "presto.configJvmAdditionalYaml" -}}
    {{- /* This collects together all jvm.additional entries */}}
    {{- range ( regexFindAll "(?m)^\\s*(dbms\\.jvm\\.additional=).+" . -1 ) }}{{ trim . | replace "dbms.jvm.additional=" "" | trim | nindent 2 }}{{- end }}
{{- end -}}
