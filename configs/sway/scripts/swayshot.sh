#!/usr/bin/env bash

filename="screenshot-`date +%F-%T`"
mkdir -p ~/pictures/screenshots
grim -g "$(slurp)" ~/pictures/screenshots/$filename.png
