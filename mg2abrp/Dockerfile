# Nutzt das offizielle, fertig gebaute Image des Community-Projekts,
# statt selbst aus dem Quellcode zu bauen (das Projekt ist inzwischen
# auf Poetry umgestellt, Details des internen Build-Prozesses aendern
# sich - das fertige Image ist die stabilere Basis).
# https://hub.docker.com/r/saicismartapi/saic-python-mqtt-gateway
FROM saicismartapi/saic-python-mqtt-gateway:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Kein eigenes CMD hier! Docker vererbt automatisch das CMD des
# Basis-Images, wenn nur ein neues ENTRYPOINT gesetzt wird. run.sh
# uebernimmt dieses ererbte CMD am Ende ueber "exec "$@"" - so muss
# der interne Skriptname des Gateways hier nicht bekannt sein.
ARG BUILD_VERSION=1.0.0
ARG BUILD_ARCH
LABEL \
  io.hass.name="MG to ABRP Bridge" \
  io.hass.description="Sendet SOC/Ladezustand deines MG live an ABRP" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  io.hass.arch=${BUILD_ARCH}

ENTRYPOINT [ "/run.sh" ]
