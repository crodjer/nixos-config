#!/usr/bin/env bash

channel=$(sudo nix-channel --list | cut -f 2 -d -) # 23.11 / unstable etc

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-$channel.tar.gz home-manager
sudo nix-channel --update
