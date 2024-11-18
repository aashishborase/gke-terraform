{{- define "my-nginx-chart.name" -}}
{{ .Chart.Name | default "nginx-app" }}
{{- end }}

{{- define "my-nginx-chart.fullname" -}}
{{ .Release.Name }}-{{ include "my-nginx-chart.name" . }}
{{- end }}
