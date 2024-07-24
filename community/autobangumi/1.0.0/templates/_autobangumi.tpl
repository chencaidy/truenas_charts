{{- define "autobangumi.workload" -}}
workload:
  autobangumi:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.autobangumiNetwork.hostNetwork }}
      containers:
        autobangumi:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.autobangumiRunAs.user }}
            runAsGroup: {{ .Values.autobangumiRunAs.group }}
          {{ with .Values.autobangumiConfig.additionalEnvs }}
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
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.autobangumiRunAs.user
                                                        "GID" .Values.autobangumiRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
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
        port: {{ .Values.autobangumiNetwork.webPort }}
        nodePort: {{ .Values.autobangumiNetwork.webPort }}
        targetPort: 7892
        targetSelector: autobangumi

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.autobangumiStorage.config) | nindent 4 }}
    targetSelector:
      autobangumi:
        autobangumi:
          mountPath: /app/config
        {{- if and (eq .Values.autobangumiStorage.config.type "ixVolume")
                  (not (.Values.autobangumiStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.autobangumiStorage.data) | nindent 4 }}
    targetSelector:
      autobangumi:
        autobangumi:
          mountPath: /app/data
        {{- if and (eq .Values.autobangumiStorage.data.type "ixVolume")
                  (not (.Values.autobangumiStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  {{- range $idx, $storage := .Values.autobangumiStorage.additionalStorages }}
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
