# NixOS Configuration

Having been a Arch / Debian user for the past decade, this is my experimentation
with NixOS as my primary distribution.

> Right now, this is all WIP and susceptible to change.

## Major Features

- Sway WM
- WezTerm
- NeoVim
- Firefox

## Layout
- `nixos-base.nix`
  Most of the configuration goes here.
- `configuration.nix` basically imports `nixos-base.nix` and is the one that
  gets symlinked to `/etc/configuration.nix`.
- `install.nix` is what can be used during installation, to be switched to
  `configuration.nix` before boot.
- `machines/`: Per machine configurations, optionally imported by base as
  `machine.nix`.
- Support for custom configuration via `local.nix`.
- `home.nix`: A recently introduced home-manager based configuration. Most
  utility comes from symlinking of home based dotfiles as some packages don't
  support global config files.
- `configs/`: Actual configuration files for few programs which aren't exposed
  by nix or aren't flexible enough for nix configuration.
- `scripts/`: A few scripts used in the config and also for setting things up.
