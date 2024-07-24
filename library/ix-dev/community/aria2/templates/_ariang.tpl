{{- define "ariang.workload" -}}
workload:
  ariang:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ariaNetwork.hostNetwork }}
      containers:
        ariang:
          enabled: true
          primary: true
          imageSelector: webImage
          securityContext:
            runAsUser: {{ .Values.ariaID.user }}
            runAsGroup: {{ .Values.ariaID.group }}
          probes:
            liveness:
              enabled: true
              type: http
              port: 6880
              path: /
            readiness:
              enabled: true
              type: http
              port: 6880
              path: /
            startup:
              enabled: true
              type: http
              port: 6880
              path: /

{{/* Service */}}
service:
  ariang:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: ariang
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.ariaNetwork.webPort }}
        nodePort: {{ .Values.ariaNetwork.webPort }}
        targetPort: 6880
        targetSelector: ariang

{{- end -}}
