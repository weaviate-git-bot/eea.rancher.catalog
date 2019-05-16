version: "2"
services:
  cynin:
    image: eeacms/cynin:3.2
    mem_reservation: 1g
    mem_limit: 2g
    labels:
      io.rancher.container.hostname_override: container_name
      {{- if .Values.HOST_LABELS}}
      io.rancher.scheduler.affinity:host_label: ${HOST_LABELS}
      {{- else}}
      io.rancher.scheduler.affinity:host_label_ne: reserved=yes
      {{- end}}
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
    depends_on:
    - zeo
    - postfix
    links:
    - zeo
    - postfix
    environment:
      SERVICES: "zope"
      TZ: "${TZ}"

  zeo:
    image: eeacms/cynin:3.2
    mem_reservation: 512m
    mem_limit: 1g
    labels:
      io.rancher.container.hostname_override: container_name
      {{- if .Values.HOST_LABELS}}
      io.rancher.scheduler.affinity:host_label: ${HOST_LABELS}
      {{- else}}
      io.rancher.scheduler.affinity:host_label_ne: reserved=yes
      {{- end}} 
    environment:
      SERVICES: "zeo"
      TZ: "${TZ}"
    volumes:
    - filestorage:/var/local/community.eea.europa.eu/var/filestorage
    - blobstorage:/var/local/community.eea.europa.eu/var/blobstorage

  postfix:
{{- if eq .Values.MAILTRAP "yes"}}
    image: eaudeweb/mailtrap
{{- else}}
    image: eeacms/postfix:2.10-3.3
    environment:
      MTP_RELAY: "ironports.eea.europa.eu"
      MTP_PORT: "8587"
      MTP_HOST: "${SERVER_NAME}"
      MTP_USER: "${POSTFIX_USER}"
      MTP_PASS: "${POSTFIX_PASS}"
      TZ: "${TZ}"
{{- end}}
    mem_reservation: 64m
    mem_limit: 128m
    labels:
      io.rancher.container.hostname_override: container_name
      {{- if .Values.HOST_LABELS}}
      io.rancher.scheduler.affinity:host_label: ${HOST_LABELS}
      {{- else}}
      io.rancher.scheduler.affinity:host_label_ne: reserved=yes
      {{- end}}

volumes:
  filestorage:
    {{- if eq .Values.DATAF_VOLUME_EXTERNAL "yes"}}
    external: true
    {{- else}}
    driver: ${DATAF_VOLUME_DRIVER}
    driver_opts:
      {{.Values.DATAF_VOLUME_DRIVER_OPTS}}
    {{- end}}
  blobstorage:
    {{- if eq .Values.DATAB_VOLUME_EXTERNAL "yes"}}
    external: true
    {{- else}}
    driver: ${DATAB_VOLUME_DRIVER}
    driver_opts:
      {{.Values.DATAB_VOLUME_DRIVER_OPTS}}
    {{- end}}   
