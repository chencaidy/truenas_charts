{{- define "npm.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{- $port := .Values.npmNetwork.webPort -}}
  {{- if .Values.npmNetwork.hostNetwork -}}
    {{- $port = 81 -}}
  {{- end }}
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
