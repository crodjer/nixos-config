{ lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    /mnt/etc/nixos/hardware-configuration.nix
    ./nixos-base.nix
  ]
  ++ lib.optional (builtins.pathExists /etc/nixos/machine.nix) /etc/nixos/machine.nix
  ++ lib.optional (builtins.pathExists /etc/nixos/swap.nix) /etc/nixos/swap.nix
  ++ lib.optional (builtins.pathExists /etc/nixos/local.nix) /etc/nixos/local.nix;
}
