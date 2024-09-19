#!/usr/bin/env bash

START=60
STOP=95
SYS_POWR_SUPPLY=/sys/class/power_supply/
BATTERY=$(ls $SYS_POWR_SUPPLY | grep BAT | head -1)
CAPACITY=$(cat $SYS_POWR_SUPPLY/$BATTERY/capacity)

tlp=/run/current-system/sw/bin/tlp

log() {
    >&2 echo "[$(date -Is)] [$BATTERY $CAPACITY%] $@"
}

if ! $tlp setcharge $START $STOP $BATTERY &> /dev/null; then
  if [[ "$CAPACITY" -gt $STOP ]]; then
    log "Enabeling battery conservation mode"
    $tlp setcharge 0 1 $BATTERY
  elif [[ "$CAPACITY" -lt $START ]]; then
    log "Disabling battery conservation mode"
    $tlp setcharge 0 0 $BATTERY
  fi
fi
