#!/usr/bin/env bash

channel=$(sudo nix-channel --list | grep nixos | cut -f 2 -d -) # 23.11 / unstable etc

if [ "$channel" = "unstable" ]; then
  archive="master"
else
  archive="release-$channel.tar.gz"
fi

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/$archive.tar.gz home-manager
sudo nix-channel --update
