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

export LOG_LEVEL="${LOG_LEVEL_VAL^^}"

echo "[INFO] Starte saic-python-mqtt-gateway ..."
echo "[INFO] MQTT Broker: ${MQTT_URI}"
echo "[INFO] SAIC Region: ${SAIC_REGION}"
if [ -n "$ABRP_USER_TOKEN" ]; then
  echo "[INFO] ABRP Telemetrie aktiv fuer VIN: ${ABRP_VIN}"
fi

cd /usr/src/app
exec python3 ./mqtt_gateway.py
