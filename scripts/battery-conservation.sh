#!/usr/bin/env bash

THRESHOLD=80

log() {
    >&2 echo "[$(date -Is)] [Battery: $BATTERY] $@"
}

set-battery-conservation-status() {
    BATTERY="$(acpi -b | grep -oP '\d+(?=%)')"
    CONSERVATION_MODE_FILE=/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
    CONSERVATION_MODE=$(cat $CONSERVATION_MODE_FILE)

    if [[ "$BATTERY" -gt $THRESHOLD && "$CONSERVATION_MODE" == "0" ]]; then
        log "Enabeling battery conservation mode"
        echo 1 | sudo tee $CONSERVATION_MODE_FILE
    elif [[ "$BATTERY" -lt $((THRESHOLD - 5)) && "$CONSERVATION_MODE" == "1" ]]; then
        log "Disabling battery conservation mode"
        echo 0 | sudo tee $CONSERVATION_MODE_FILE
    fi
}

set-battery-conservation-status
