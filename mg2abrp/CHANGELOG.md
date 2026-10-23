# Changelog

## 1.1.0
- Neu: Live-Daten an Meeterz (Akkustand, Reichweite, Laden, Außentemperatur, Position).
  Optionen `meeterz_url` und `meeterz_device_id` (beides aus der Meeterz-App: Einstellungen → E-Auto → Live-Daten).
  Nutzt die OsmAnd-Schnittstelle des Gateways; Geschwindigkeit in km/h.
- Neu: Option `vin` (falls ABRP nicht genutzt wird; sonst gilt `abrp_vin`).
- ABRP-Felder sind jetzt optional, damit das Add-on auch nur für Meeterz laufen kann.

## 1.0.2
- Fix: CMD wurde beim Setzen eines eigenen ENTRYPOINT von Docker
  zurueckgesetzt statt vom Basis-Image geerbt (Docker-Standardverhalten).
  CMD wird jetzt explizit gesetzt ("python", "./main.py").
  Das war der Grund fuer den lautlosen Sofort-Exit/Neustart-Loop.

## 1.0.1
- Dockerfile auf offizielles Basis-Image umgestellt (saicismartapi/saic-python-mqtt-gateway)
- PYTHONUNBUFFERED gesetzt, damit Fehler im Log sichtbar werden
- USER root vor apt-get, da Basis-Image als Non-Root laeuft

## 1.0.0
- Erstes Release
- Basiert auf saic-python-mqtt-gateway (SAIC-iSmart-API Community-Projekt)
- ABRP-Token direkt über die Add-on-Konfiguration setzbar
- Home Assistant MQTT-Discovery aktivierbar
