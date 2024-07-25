{{- define "aria2.workload" -}}
workload:
  aria2:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ariaNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.ariaID.group }}
      containers:
        aria2:
          enabled: true
          primary: true
          imageSelector: serverImage
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
          env:
            RPC_PORT: 6800
            LISTEN_PORT: 6888
            RPC_SECRET: {{ .Values.ariaConfig.rpcSecret }}
          fixedEnv:
            PUID: {{ .Values.ariaID.user }}
          {{ with .Values.ariaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: 6800
            readiness:
              enabled: true
              type: tcp
              port: 6800
            startup:
              enabled: true
              type: tcp
              port: 6800

{{/* Service */}}
service:
  aria2:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: aria2
    ports:
      rpc:
        enabled: true
        port: 6800
        nodePort: {{ .Values.ariaNetwork.rpcPort }}
        targetPort: 6800
        targetSelector: aria2
      listen:
        enabled: true
        port: 6888
        nodePort: {{ .Values.ariaNetwork.listenPort }}
        targetPort: 6888
        targetSelector: aria2

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ariaStorage.config) | nindent 4 }}
    targetSelector:
      aria2:
        aria2:
          mountPath: /config
        {{- if and (eq .Values.ariaStorage.config.type "ixVolume")
                  (not (.Values.ariaStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  downloads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ariaStorage.downloads) | nindent 4 }}
    targetSelector:
      aria2:
        aria2:
          mountPath: /downloads
        {{- if and (eq .Values.ariaStorage.downloads.type "ixVolume")
                  (not (.Values.ariaStorage.downloads.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/downloads
        {{- end }}
  {{- range $idx, $storage := .Values.ariaStorage.additionalStorages }}
  {{ printf "aria2-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      aria2:
        aria2:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
