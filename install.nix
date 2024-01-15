{
  imports = [
    # Include the results of the hardware scan.
    /mnt/etc/nixos/hardware-configuration.nix
    ./nixos-base.nix
  ];
}
