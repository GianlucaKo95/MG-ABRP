# MG to ABRP Bridge (Add-on)

Verbindet dein MG (iSMART/SAIC-Konto) mit Home Assistant per MQTT und sendet
den Ladezustand live an A Better Route Planner (ABRP) — ohne OBD-Dongle.

Basiert auf dem aktiv gepflegten Community-Projekt
[`saic-python-mqtt-gateway`](https://github.com/SAIC-iSmart-API/saic-python-mqtt-gateway).

## Voraussetzungen

1. **Mosquitto broker** Add-on installiert und gestartet (Add-on Store →
   offizielles Add-on "Mosquitto broker")
2. **MQTT Integration** in Home Assistant eingerichtet (Einstellungen →
   Geräte & Dienste → Integration hinzufügen → MQTT). Meist reicht "autodiscover".
3. Ein MG iSMART Konto mit registriertem Fahrzeug
4. Die **VIN** (Fahrzeug-Identifikationsnummer) deines Fahrzeugs — findest du
   in der iSMART App unter Fahrzeugdetails, oder im Fahrzeugschein
5. Ein ABRP-Konto mit **Generic Token** für dein Fahrzeug

## Login zu deinem MG iSMART Konto

Du nutzt für `saic_username` / `saic_password` exakt dieselben Zugangsdaten
wie in der iSMART App — es gibt keinen separaten API-Key oder OAuth-Flow.

- `saic_username`: deine **E-Mail-Adresse** oder deine **Telefonnummer**,
  je nachdem, wie du dich auch in der App anmeldest
- `saic_password`: dasselbe Passwort wie in der App
- `saic_phone_country_code`: **nur** ausfüllen, wenn du dich per
  Telefonnummer anmeldest (z. B. `49` für Deutschland). Bei E-Mail-Login
  leer lassen

**Stolperfallen:**

- Bei Telefonnummer-Login **nicht** die volle Nummer inkl. `+` und
  Ländercode in `saic_username` eintragen — der Ländercode gehört in das
  separate Feld `saic_phone_country_code`, `saic_username` bekommt nur die
  restliche Nummer ohne führende Null/Plus
- SAIC sperrt das Konto nach ca. 5 fehlgeschlagenen Login-Versuchen pro Tag.
  Bei Login-Fehlern lieber kurz in der App gegenprüfen, ob die Zugangsdaten
  noch stimmen, statt mehrfach zu probieren
- Es ist **kein 2FA/SMS-Code** nötig — reiner Benutzername+Passwort-Login
- Paralleles Nutzen der offiziellen App ist grundsätzlich unproblematisch,
  nur bei zeitgleichen aktiven Abfragen kann SAIC die Gateway-Session kurz
  pausieren (siehe Abschnitt "Wichtige Hinweise")

## Welche Daten sendet das Add-on an ABRP?

Sobald `abrp_vin` und `abrp_token` gesetzt sind, sendet das Gateway
automatisch **alle** Telemetriedaten an ABRP, die es vom Fahrzeug bekommt —
nicht nur den SOC. Eine manuelle Auswahl einzelner Felder ist nicht nötig
oder möglich.

| Feld | Zweck | Praktisch nötig? |
| --- | --- | --- |
| `soc` | Ladezustand der Batterie | Kern-Information |
| `lat` / `lon` | Position des Fahrzeugs | Ohne Position kann ABRP dich nicht live auf der geplanten Route verorten und die Route nicht nachjustieren |
| `speed` | Geschwindigkeit | Verbessert die Verbrauchsvorhersage |
| `power` / `current` / `voltage` | Momentaner Energiefluss | Verbessert die Verbrauchsvorhersage |
| `is_charging` | Lädt das Fahrzeug gerade? | Für korrekte Reichweiten-/Ladeplanung |
| `car_model` | Fahrzeugmodell | Wird einmalig beim Verbinden des "Generic"-Tokens in ABRP festgelegt, nicht bei jeder Übertragung |

Da die SAIC-Cloud sowohl SOC als auch GPS-Position und Ladezustand liefert,
bekommt ABRP über dieses Add-on das volle Paket und kann damit deutlich
genauer planen als bei einer reinen SOC-only-Anbindung.

## ABRP Token besorgen

1. ABRP öffnen (App oder [abetterrouteplanner.com](https://abetterrouteplanner.com))
2. Fahrzeug auswählen → **Live Data** / **Verbindung**
3. **"Link vehicle"** → **"Generic"** wählen
4. Angezeigten Token kopieren

## Konfiguration

| Option | Beschreibung |
| --- | --- |
| `saic_username` | E-Mail/Benutzername deines iSMART-Kontos |
| `saic_password` | Passwort deines iSMART-Kontos |
| `saic_phone_country_code` | Nur nötig, falls du dich mit Telefonnummer statt E-Mail anmeldest (z. B. `49`) |
| `saic_region` | `eu` für Europa (Standard), `au` für Australien/Neuseeland, `tr` für Türkei |
| `mqtt_host` | Adresse deines MQTT-Brokers. Bei lokalem Mosquitto-Add-on: `core-mosquitto` |
| `mqtt_port` | Standard `1883` |
| `mqtt_username` / `mqtt_password` | Zugangsdaten für den MQTT-Broker (bei Mosquitto-Add-on: der dort angelegte Nutzer) |
| `ha_discovery` | `true` = Fahrzeug erscheint automatisch als Gerät/Sensoren in Home Assistant |
| `abrp_vin` | VIN deines Fahrzeugs (siehe oben) |
| `abrp_token` | Der "Generic"-Token aus ABRP (siehe oben) |
| `abrp_api_key` | Optional — Standardmäßig wird der öffentliche Open-Source-Telemetrie-Key des Gateway-Projekts verwendet. Nur ändern, wenn du einen eigenen Iternio-Entwickler-Key hast. |
| `log_level` | `debug`, `info` (Standard), `warning`, `error`, `critical` |

## Beispiel-Konfiguration

```yaml
saic_username: "deine-email@example.com"
saic_password: "dein-ismart-passwort"
saic_phone_country_code: ""
saic_region: "eu"
mqtt_host: "core-mosquitto"
mqtt_port: 1883
mqtt_username: "mqtt_user"
mqtt_password: "mqtt_passwort"
ha_discovery: true
abrp_vin: "LSJXXXXXXXXXXXXXX"
abrp_token: "12345678-abcd-1234-abcd-1234567890ab"
abrp_api_key: ""
log_level: "info"
```

## Nach dem Start

- In den Add-on-Logs solltest du sehen, dass sich das Gateway erfolgreich
  bei SAIC einloggt und ABRP-Telemetrie aktiv ist
- In Home Assistant taucht dein Fahrzeug automatisch als Gerät mit Sensoren
  (SOC, Reichweite, Ladezustand, Standort, ...) auf, sofern `ha_discovery`
  aktiviert ist
- ABRP zeigt den Ladezustand in Echtzeit an, sobald das Gateway erfolgreich
  Daten sendet (abhängig vom Poll-Verhalten der SAIC-Cloud, i. d. R. wenige
  Minuten Verzögerung im Stand, schneller während der Fahrt)

## Wichtige Hinweise

- Wenn du gleichzeitig die offizielle iSMART-App nutzt, kann es zu kurzen
  Unterbrechungen kommen (SAIC pausiert die Gateway-Session für ca. 15
  Minuten, wenn ein anderes Gerät sich einloggt)
- Nutzung erfolgt über nicht offiziell von SAIC/MG dokumentierte
  Endpunkte — für privaten Gebrauch übliches, aber inoffizielles Vorgehen

## Live-Daten an Meeterz (optional)

Die iPhone-/CarPlay-App Meeterz kann Akkustand, Reichweite und Ladezustand live übernehmen
(für die Ladeplanung und statt der Akku-Eingabe in CarPlay).

1. In Meeterz: Einstellungen → App → E-Auto → **Live-Daten** → „Live-Daten verbinden“.
2. Die angezeigte **Server-Adresse** in `meeterz_url` und die **Geräte-ID** in `meeterz_device_id` eintragen.
3. Falls kein ABRP genutzt wird: die Fahrgestellnummer in `vin` eintragen (sonst gilt `abrp_vin`).
4. Add-on neu starten. Im Log erscheint „Meeterz Live-Daten aktiv“.

Technisch nutzt das Gateway seine OsmAnd-Schnittstelle (wie für Traccar); gesendet werden u. a.
`soc`, `est_battery_range`, `is_charging`, `power`, `ext_temp`, `odometer`, `speed`, `lat`/`lon`.
Beim Fahren etwa alle 30 Sekunden, geparkt deutlich seltener. Die Geräte-ID ist geheim – wer sie kennt,
kann Werte für dein Konto schreiben (aber nichts lesen). In der App lässt sich jederzeit eine neue erzeugen.
