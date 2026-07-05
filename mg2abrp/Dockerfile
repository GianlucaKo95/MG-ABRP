# Kein ARG BUILD_FROM mehr - seit Supervisor 2026.04.0 nicht mehr automatisch
# befuellt. Direktes FROM, python-Images sind ohnehin multi-arch
# (unterstuetzen amd64/aarch64/armv7 ueber ein Manifest).
FROM python:3.12-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends git jq ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Offizielles, aktiv gepflegtes Community-Projekt klonen
# https://github.com/SAIC-iSmart-API/saic-python-mqtt-gateway
ARG GATEWAY_REF=main
RUN git clone --depth 1 --branch ${GATEWAY_REF} \
    https://github.com/SAIC-iSmart-API/saic-python-mqtt-gateway.git . && \
    pip install --no-cache-dir -r requirements.txt

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Erforderlich, da kein offizieller HA-Builder verwendet wird
ARG BUILD_VERSION=1.0.0
ARG BUILD_ARCH
LABEL \
  io.hass.name="MG to ABRP Bridge" \
  io.hass.description="Sendet SOC/Ladezustand deines MG live an ABRP" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  io.hass.arch=${BUILD_ARCH}

CMD [ "/run.sh" ]
