# Changelog

## 1.0.1
- Dockerfile auf offizielles Basis-Image umgestellt (saicismartapi/saic-python-mqtt-gateway)
- PYTHONUNBUFFERED gesetzt, damit Fehler im Log sichtbar werden
- USER root vor apt-get, da Basis-Image als Non-Root laeuft

## 1.0.0
- Erstes Release
- Basiert auf saic-python-mqtt-gateway (SAIC-iSmart-API Community-Projekt)
- ABRP-Token direkt über die Add-on-Konfiguration setzbar
- Home Assistant MQTT-Discovery aktivierbar
