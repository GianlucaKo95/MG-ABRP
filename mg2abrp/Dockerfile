# Nutzt das offizielle, fertig gebaute Image des Community-Projekts,
# statt selbst aus dem Quellcode zu bauen (das Projekt ist inzwischen
# auf Poetry umgestellt, Details des internen Build-Prozesses aendern
# sich - das fertige Image ist die stabilere Basis).
# https://hub.docker.com/r/saicismartapi/saic-python-mqtt-gateway
FROM saicismartapi/saic-python-mqtt-gateway:latest

# Das Basis-Image laeuft standardmaessig als Non-Root-User (daher
# schlug apt-get zuvor mit "Permission denied" fehl). Fuer dieses
# private Add-on bleiben wir bewusst als root - das Docker-Container-
# Sandboxing bietet ohnehin die eigentliche Isolation, und so muss
# der genaue interne Nutzername des Basis-Images nicht bekannt sein.
USER root

# Erzwingt unverzoegerte Python-Ausgaben - ohne das koennten Fehler
# beim Absturz im Ausgabepuffer verschwinden, bevor sie im Log
# landen (genau das Symptom: keine Fehlermeldung, nur stiller Crash).
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# ENTRYPOINT + explizites CMD (siehe unten) - run.sh uebernimmt die
# Werte per "exec "$@"" und startet damit den Original-Befehl.
ARG BUILD_VERSION=1.0.0
ARG BUILD_ARCH
LABEL \
  io.hass.name="MG to ABRP Bridge" \
  io.hass.description="Sendet SOC/Ladezustand deines MG live an ABRP" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  io.hass.arch=${BUILD_ARCH}

# Docker-Verhalten (oft missverstanden): Setzt man in einem
# abgeleiteten Image ein neues ENTRYPOINT, wird ein vom Basis-Image
# geerbtes CMD NICHT uebernommen, sondern auf leer zuruecksetzt.
# Deshalb muss der Original-Befehl hier explizit wiederholt werden.
# (Ermittelt per Registry-API-Abfrage der Basis-Image-Config.)
ENTRYPOINT [ "/run.sh" ]
CMD [ "python", "./main.py" ]
