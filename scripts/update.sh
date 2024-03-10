#!/usr/bin/env bash

set -e

sudo nixos-rebuild switch --upgrade
flatpak update -y
