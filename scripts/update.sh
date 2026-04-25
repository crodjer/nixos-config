#!/usr/bin/env bash

set -e

sudo nix-channel --update
sudo nixos-rebuild switch --upgrade

if [ -n "${commands[flatpak]}" ]; then
  flatpak update -y
fi
