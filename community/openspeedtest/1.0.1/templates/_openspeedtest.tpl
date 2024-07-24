{{- define "openspeedtest.workload" -}}
workload:
  openspeedtest:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ostNetwork.hostNetwork }}
      containers:
        openspeedtest:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 101
            runAsGroup: 101
            readOnlyRootFilesystem: false
            runAsNonRoot: false
          {{ with .Values.ostConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /
              port: 3000
            readiness:
              enabled: true
              type: http
              path: /
              port: 3000
            startup:
              enabled: true
              type: http
              path: /
              port: 3000

{{/* Service */}}
service:
  openspeedtest:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: openspeedtest
    ports:
      openspeedtest:
        enabled: true
        primary: true
        port: {{ .Values.ostNetwork.webPort }}
        nodePort: {{ .Values.ostNetwork.webPort }}
        targetPort: 3000
        targetSelector: openspeedtest
{{- end -}}
