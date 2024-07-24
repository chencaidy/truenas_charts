{{- define "autobangumi.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{- $port := .Values.abNetwork.webPort -}}
  {{- if .Values.abNetwork.hostNetwork -}}
    {{- $port = 7892 -}}
  {{- end }}
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
