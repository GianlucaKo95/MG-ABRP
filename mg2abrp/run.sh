#!/bin/bash
set -e

OPTIONS_FILE="/data/options.json"

get_opt() {
  jq -r ".$1 // \"\"" "$OPTIONS_FILE"
}

SAIC_USERNAME=$(get_opt saic_username)
SAIC_PASSWORD_VAL=$(get_opt saic_password)
SAIC_PHONE_CC=$(get_opt saic_phone_country_code)
SAIC_REGION_VAL=$(get_opt saic_region)
MQTT_HOST=$(get_opt mqtt_host)
MQTT_PORT_VAL=$(get_opt mqtt_port)
MQTT_USERNAME=$(get_opt mqtt_username)
MQTT_PASSWORD_VAL=$(get_opt mqtt_password)
HA_DISCOVERY_VAL=$(get_opt ha_discovery)
ABRP_VIN=$(get_opt abrp_vin)
ABRP_TOKEN_VAL=$(get_opt abrp_token)
ABRP_API_KEY_VAL=$(get_opt abrp_api_key)
LOG_LEVEL_VAL=$(get_opt log_level)
MEETERZ_URL=$(get_opt meeterz_url)
MEETERZ_DEVICE_ID=$(get_opt meeterz_device_id)
VIN_VAL=$(get_opt vin)
[ -z "$VIN_VAL" ] && VIN_VAL="$ABRP_VIN"

if [ -z "$SAIC_USERNAME" ] || [ -z "$SAIC_PASSWORD_VAL" ]; then
  echo "[FATAL] saic_username und saic_password muessen in der Add-on Konfiguration gesetzt sein."
  exit 1
fi

if [ -z "$ABRP_VIN" ] || [ -z "$ABRP_TOKEN_VAL" ]; then
  echo "[WARN] abrp_vin oder abrp_token nicht gesetzt - es wird KEINE Telemetrie an ABRP gesendet."
  echo "[WARN] Das Gateway laeuft trotzdem und befuellt Home Assistant per MQTT."
fi

export SAIC_USER="$SAIC_USERNAME"
export SAIC_PASSWORD="$SAIC_PASSWORD_VAL"
[ -n "$SAIC_PHONE_CC" ] && export SAIC_PHONE_COUNTRY_CODE="$SAIC_PHONE_CC"

case "$SAIC_REGION_VAL" in
  au)
    export SAIC_REST_URI="https://gateway-mg-au.soimt.com/api.app/v1/"
    export SAIC_REGION="au"
    ;;
  tr)
    export SAIC_REST_URI="https://gateway-mg-tr.soimt.com/api.app/v1/"
    export SAIC_REGION="tr"
    ;;
  *)
    export SAIC_REST_URI="https://gateway-mg-eu.soimt.com/api.app/v1/"
    export SAIC_REGION="eu"
    ;;
esac

export MQTT_URI="tcp://${MQTT_HOST}:${MQTT_PORT_VAL}"
[ -n "$MQTT_USERNAME" ] && export MQTT_USER="$MQTT_USERNAME"
[ -n "$MQTT_PASSWORD_VAL" ] && export MQTT_PASSWORD="$MQTT_PASSWORD_VAL"

if [ "$HA_DISCOVERY_VAL" = "true" ]; then
  export HA_DISCOVERY_ENABLED="True"
else
  export HA_DISCOVERY_ENABLED="False"
fi

if [ -n "$ABRP_VIN" ] && [ -n "$ABRP_TOKEN_VAL" ]; then
  export ABRP_USER_TOKEN="${ABRP_VIN}=${ABRP_TOKEN_VAL}"
fi
[ -n "$ABRP_API_KEY_VAL" ] && export ABRP_API_KEY="$ABRP_API_KEY_VAL"

# Meeterz: Live-Daten ueber die OsmAnd-Schnittstelle des Gateways an die Supabase-Edge-Function
# "vehicle-telemetry". Die Geraete-ID (aus der Meeterz-App) ist das geheime Token.
if [ -n "$MEETERZ_URL" ] && [ -n "$MEETERZ_DEVICE_ID" ]; then
  if [ -z "$VIN_VAL" ]; then
    echo "[WARN] Meeterz: keine VIN gesetzt (Option 'vin' oder 'abrp_vin') - Live-Daten an Meeterz deaktiviert."
  else
    export OSMAND_SERVER_URI="$MEETERZ_URL"
    export OSMAND_DEVICE_ID="${VIN_VAL}=${MEETERZ_DEVICE_ID}"
    export OSMAND_USE_KNOTS="False"
    echo "[INFO] Meeterz Live-Daten aktiv fuer VIN: ${VIN_VAL}"
  fi
fi

export LOG_LEVEL="${LOG_LEVEL_VAL^^}"

echo "[INFO] Starte saic-python-mqtt-gateway ..."
echo "[INFO] MQTT Broker: ${MQTT_URI}"
echo "[INFO] SAIC Region: ${SAIC_REGION}"
if [ -n "$ABRP_USER_TOKEN" ]; then
  echo "[INFO] ABRP Telemetrie aktiv fuer VIN: ${ABRP_VIN}"
fi

# Meeterz: Restladezeit laut Auto. Das Gateway schickt sie nicht ueber OsmAnd, veroeffentlicht sie aber per MQTT
# (<topic>/<user>/vehicles/<vin>/drivetrain/remainingChargingTime, Sekunden). Mitlesen und einzeln weiterreichen.
if [ -n "$OSMAND_DEVICE_ID" ]; then
  (
    SUB_ARGS=(-h "$MQTT_HOST" -p "${MQTT_PORT_VAL:-1883}" -t "+/+/vehicles/${VIN_VAL}/drivetrain/remainingChargingTime")
    [ -n "$MQTT_USERNAME" ] && SUB_ARGS+=(-u "$MQTT_USERNAME")
    [ -n "$MQTT_PASSWORD_VAL" ] && SUB_ARGS+=(-P "$MQTT_PASSWORD_VAL")
    while true; do
      mosquitto_sub "${SUB_ARGS[@]}" | while read -r SECONDS_LEFT; do
        curl -fsS -m 15 -X POST "${MEETERZ_URL}?id=${MEETERZ_DEVICE_ID}&remaining_charging_time=${SECONDS_LEFT}" >/dev/null \
          || echo "[WARN] Meeterz: Restladezeit nicht gesendet"
      done
      echo "[WARN] Meeterz: MQTT-Verbindung fuer die Restladezeit getrennt - neuer Versuch in 30 s"
      sleep 30
    done
  ) &
  echo "[INFO] Meeterz Restladezeit wird per MQTT mitgelesen"
fi

# Kein fest angenommener Skriptname: fuehrt das vom Basis-Image
# ererbte CMD aus (siehe Dockerfile-Kommentar).
exec "$@"
