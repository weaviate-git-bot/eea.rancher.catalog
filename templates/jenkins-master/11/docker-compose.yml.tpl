version: "2"
services:
  master:
    image: eeacms/jenkins-master:2.121.3
    {{- if .Values.JENKINS_MASTER_PORT}}
    ports:
    - "${JENKINS_MASTER_PORT}:8080"
    {{- if .Values.JENKINS_SLAVE_PORT}}
    - "${JENKINS_SLAVE_PORT}:50000"
    {{- end}}
    {{- end}}
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.scheduler.affinity:host_label: ${HOST_LABELS}
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
    depends_on:
    - postfix
    environment:
      JAVA_OPTS: "-Xmx2048m"
      TZ: "${TZ}"
      JENKINS_OPTS: "--sessionTimeout=${JENKINS_SESSION_TIMEOUT}"
    volumes:
    - jenkins-master:/var/jenkins_home

  postfix:
    image: eeacms/postfix:2.10-3.3
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.scheduler.affinity:host_label: ${HOST_LABELS}
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
    environment:
      TZ: "${TZ}"
      MTP_HOST: "${SERVER_NAME}"
      MTP_RELAY: "${POSTFIX_RELAY}"
      MTP_PORT: "${POSTFIX_PORT}"
      MTP_USER: "${POSTFIX_USER}"
      MTP_PASS: "${POSTFIX_PASS}"

{{- if eq .Values.VOLUME_DRIVER "rancher-ebs"}}

volumes:
  jenkins-master:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      {{.Values.VOLUME_DRIVER_OPTS}}

{{- end}}
