#!/usr/bin/env bash

set -e

sudo nixos-rebuild switch --upgrade

if [ -n "${commands[flatpak]}" ]; then
  flatpak update -y
fi
