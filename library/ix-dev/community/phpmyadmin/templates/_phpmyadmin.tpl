{{- define "phpmyadmin.workload" -}}
workload:
  phpmyadmin:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.pmaID.group }}
      containers:
        phpmyadmin:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: false
            runAsNonRoot: false
            capabilities:
              add:
                - CHOWN
                - SETGID
                - SETUID
                - FOWNER
                - DAC_OVERRIDE
                - NET_BIND_SERVICE
          env:
            PMA_HOST: {{ .Values.pmaConfig.dbHost }}
            PMA_PORT: {{ .Values.pmaConfig.dbPort }}
          fixedEnv:
            PUID: {{ .Values.pmaID.user }}
          {{ with .Values.pmaConfig.additionalEnvs }}
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
              port: 80
            readiness:
              enabled: true
              type: http
              path: /
              port: 80
            startup:
              enabled: true
              type: http
              path: /
              port: 80

{{/* Service */}}
service:
  phpmyadmin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: phpmyadmin
    ports:
      webui:
        enabled: true
        primary: true
        port: 80
        nodePort: {{ .Values.pmaNetwork.webPort }}
        targetPort: 80
        targetSelector: phpmyadmin

{{- end -}}
