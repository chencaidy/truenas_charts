{{- define "autobangumi.workload" -}}
workload:
  autobangumi:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.abNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.abID.group }}
      containers:
        autobangumi:
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
          fixedEnv:
            PUID: {{ .Values.abID.user }}
          {{ with .Values.abConfig.additionalEnvs }}
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
              port: 7892
              path: /
            readiness:
              enabled: true
              type: http
              port: 7892
              path: /
            startup:
              enabled: true
              type: http
              port: 7892
              path: /

{{/* Service */}}
service:
  autobangumi:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: autobangumi
    ports:
      webui:
        enabled: true
        primary: true
        port: 7892
        nodePort: {{ .Values.abNetwork.webPort }}
        targetPort: 7892
        targetSelector: autobangumi

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.abStorage.config) | nindent 4 }}
    targetSelector:
      autobangumi:
        autobangumi:
          mountPath: /app/config
        {{- if and (eq .Values.abStorage.config.type "ixVolume")
                  (not (.Values.abStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.abStorage.data) | nindent 4 }}
    targetSelector:
      autobangumi:
        autobangumi:
          mountPath: /app/data
        {{- if and (eq .Values.abStorage.data.type "ixVolume")
                  (not (.Values.abStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  {{- range $idx, $storage := .Values.abStorage.additionalStorages }}
  {{ printf "autobangumi-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      autobangumi:
        autobangumi:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
