#!/usr/bin/env sh

if [[ "$(gsettings get org.gnome.desktop.interface color-scheme || true)" =~ "dark" ]]; then
  export DARK_MODE=true
  export BAT_THEME=nord
else
  export BAT_THEME=nord-light
fi

export GOPATH="$HOME/.local/share/go"
export PATH="$HOME/.cargo/bin:$PATH"
