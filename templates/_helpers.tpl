{{/*
Define the pgbouncer.name template
*/}}
{{- define "pgbouncer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pgbouncer.fullname" -}}
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
{{- define "pgbouncer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pgbouncer.labels" -}}
helm.sh/chart: {{ include "pgbouncer.chart" . }}
{{ include "pgbouncer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pgbouncer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pgbouncer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pgbouncer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pgbouncer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config secret to use
*/}}
{{- define "pgbouncer.configSecret" -}}
{{- if .Values.configSecretName }}
{{- .Values.configSecretName }}
{{- else }}
{{- include "pgbouncer.fullname" . }}-config
{{- end }}
{{- end }}

{{/*
Create the name of the stats secret to use
*/}}
{{- define "pgbouncer.statsSecret" -}}
{{- if .Values.metricsExporter.statsSecretName }}
{{- .Values.metricsExporter.statsSecretName }}
{{- else }}
{{- include "pgbouncer.fullname" . }}-stats
{{- end }}
{{- end }}

{{/*
Create the name of the certificates secret to use
*/}}
{{- define "pgbouncer.certificatesSecret" -}}
{{- include "pgbouncer.fullname" . }}-certificates
{{- end }}

{{/*
Create the name of the registry secret to use
*/}}
{{- define "pgbouncer.registrySecret" -}}
{{- if .Values.registry.secretName }}
{{- .Values.registry.secretName }}
{{- else }}
{{- include "pgbouncer.fullname" . }}-registry
{{- end }}
{{- end }}

{{/*
PgBouncer ini configuration
*/}}
{{- define "pgbouncer.ini" -}}
[databases]
{{ .Values.databases }}

{{- if .Values.extraIniMetadata }}
{{ .Values.extraIniMetadata }}
{{- end }}

{{- if .Values.extraIniResultBackend }}
{{ .Values.extraIniResultBackend }}
{{- end }}

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = {{ .Values.ports.pgbouncer }}
auth_file = /etc/pgbouncer/users.txt
auth_type = md5
pool_mode = session
max_client_conn = 100
default_pool_size = 20
ignore_startup_parameters = extra_float_digits
server_reset_query = DISCARD ALL
server_check_query = select 1
server_check_delay = 10
max_prepared_statements = {{ .Values.maxPreparedStatements }}
application_name_add_host = 1

# Log settings
admin_users = postgres
stats_users = postgres
verbose = {{ .Values.verbose }}
log_disconnections = {{ .Values.logDisconnections }}
log_connections = {{ .Values.logConnections }}

# Connection sanity checks, timeouts
server_idle_timeout = 60
server_lifetime = 1200
server_connect_timeout = 15
query_timeout = 120
client_idle_timeout = 60

# TLS settings
{{- if or .Values.ssl.ca .Values.ssl.cert .Values.ssl.key }}
client_tls_sslmode = {{ .Values.sslmode }}
client_tls_ca_file = /etc/pgbouncer/ca.crt
client_tls_key_file = /etc/pgbouncer/server.key
client_tls_cert_file = /etc/pgbouncer/server.crt
client_tls_ciphers = {{ .Values.ciphers }}
{{- end }}

{{- if .Values.extraIni }}
{{ .Values.extraIni }}
{{- end }}
{{- end }}

{{/*
PgBouncer users configuration
*/}}
{{- define "pgbouncer.users" -}}
{{- range $username, $password := .Values.users }}
"{{ $username }}" "{{ $password }}"
{{- end }}
{{- end }}
