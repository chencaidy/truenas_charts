{{- define "ariang.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{- $port := .Values.ariaNetwork.webPort -}}
  {{- if .Values.ariaNetwork.hostNetwork -}}
    {{- $port = 6880 -}}
  {{- end }}
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
