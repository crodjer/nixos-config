#!/usr/bin/env bash

set -e

SWAP_FILE=/var/swapfile
# Get memory size in MBs
MEM_SIZE=$(free -m | grep Mem | awk '{print $2}')
# Get swap size to be the ceil of it in GBs
SWAP_SIZE_GB=$(((MEM_SIZE+1024)/1024))
SWAP_SIZE=$((SWAP_SIZE_GB * 1024))
SWAP_NIX_CONFIG=/etc/nixos/swap.nix


if [ ! -e $SWAP_FILE ]; then
  CONFIGURATION="{\n  swapDevices = [ { device = \"$SWAP_FILE\"; size = $SWAP_SIZE; } ];\n}"
  >&2 echo "No swapfile exists, generating that first!"
  echo -e "$CONFIGURATION"
	read -p "Okay? [Y/n]: " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Y]$ ]]
	then
		exit 1
	fi
  echo -e "$CONFIGURATION" | sudo tee $SWAP_NIX_CONFIG
  echo "Rebuilding nixos..."
	sudo nixos-rebuild test
fi

OFFSET=$(sudo filefrag -v $SWAP_FILE | awk '{ if($1=="0:"){print substr($4, 1, length($4)-2)} }')
RESUME_DEVICE=$(findmnt -no UUID -T $SWAP_FILE)
SWAP_SIZE=$(ls -s --block-size=M $SWAP_FILE | grep -Po "^\d+" )

CONFIGURATION=$(cat << EOF
{
  swapDevices = [ { device = "$SWAP_FILE"; size = $SWAP_SIZE; } ];
  boot.kernelParams = ["resume_offset=$OFFSET"];
  boot.resumeDevice = "/dev/disk/by-uuid/$RESUME_DEVICE";
}
EOF
)
echo -e "$CONFIGURATION" | sudo tee $SWAP_NIX_CONFIG
echo "Rebuilding nixos..."
sudo nixos-rebuild switch
