{
  # This is a template to configure hiberation when needed.
  # Set the size according to the system RAM
  swapDevices = [ { device = "/var/swapfile"; size = 8192; } ];
  # Get this using: filefrag -v /var/swapfile
  boot.kernelParams = ["resume_offset=<offset>"];
  # The uuid for `/` partition.
  boot.resumeDevice = "/dev/disk/by-uuid/<uuid-for-root-partition>";
}
