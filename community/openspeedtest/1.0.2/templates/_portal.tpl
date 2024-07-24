{{- define "openspeedtest.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{- $port := .Values.ostNetwork.webPort -}}
  {{- if .Values.ostNetwork.hostNetwork -}}
    {{- $port = 3000 -}}
  {{- end }}
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
