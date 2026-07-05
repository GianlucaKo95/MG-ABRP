# MG → ABRP Home Assistant Add-on Repository

Dieses Repository enthält ein Home Assistant Add-on, das den Ladezustand
(State of Charge) und weitere Telemetriedaten eines MG-Fahrzeugs (MG4, MG5,
ZS EV, ...) über das MG iSMART / SAIC-Konto abruft und automatisch an
[A Better Route Planner (ABRP)](https://abetterrouteplanner.com/) sendet –
ganz ohne OBD-Dongle.

## Was macht das Add-on?

- Loggt sich mit deinen MG iSMART Zugangsdaten in die SAIC-Cloud ein
  (`saic-python-mqtt-gateway`, aktiv gepflegtes Community-Projekt)
- Erstellt automatisch Sensoren in Home Assistant (SOC, Reichweite,
  Ladezustand, Standort, ...) via MQTT-Discovery
- Ein kleiner Bridge-Prozess liest den SOC-Sensor über die lokale
  Home-Assistant-API und schickt ihn periodisch an ABRP
- Der ABRP-Token wird direkt in der Add-on-Konfiguration (UI) gesetzt

## Installation

1. In Home Assistant: **Einstellungen → Add-ons → Add-on Store**
2. Oben rechts auf die drei Punkte → **Repositories**
3. Diese URL eintragen:
   `https://github.com/GianlucaKo95/mg-abrp-addon`
4. Das Add-on **"MG to ABRP Bridge"** erscheint in der Liste → installieren
5. Konfiguration ausfüllen (siehe `mg2abrp/README.md`) → Add-on starten

## Voraussetzungen

- Ein lokal laufender MQTT-Broker (z. B. das offizielle
  **Mosquitto broker** Add-on aus dem HA-Add-on-Store)
- Ein MG iSMART Konto mit registriertem Fahrzeug
- Ein ABRP-Konto mit hinterlegtem Fahrzeug und generiertem
  **"Generic"-Token** (siehe unten)

## ABRP Token besorgen

1. ABRP App/Web öffnen → Fahrzeug auswählen
2. **Live Data** → **Link vehicle** → **Generic**
3. Den angezeigten Token kopieren und in die Add-on-Konfiguration eintragen

## Rechtlicher Hinweis

Die Nutzung basiert auf reverse-engineerten, nicht offiziell von SAIC/MG
dokumentierten API-Endpunkten (Community-Projekt `SAIC-iSmart-API`). Die
Nutzung erfolgt auf eigenes Risiko und ausschließlich für den privaten,
nicht-kommerziellen Gebrauch.
