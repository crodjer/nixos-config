#!/usr/bin/env bash

set -e

sudo nixos-rebuild switch --upgrade
flatpak update -y
rustup update
cargo install-update -a
