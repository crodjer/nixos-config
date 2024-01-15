## Steps
From: https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5

```bash
sudo cryptsetup luksFormat /dev/nvme0n1p2 --label nixos
sudo cryptsetup open /dev/disk/by-label/nixos nixos
sudo mkfs.btrfs /dev/mapper/nixos -L nixos-fs
sudo mount /dev/mapper/nixos /mnt
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/home
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/log
sudo umount /mnt

sudo mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos-fs /mnt
sudo mkdir /mnt/home
sudo mount -o subvol=home,compress=zstd,noatime /dev/disk/by-label/nixos-fs /mnt/home

sudo mkdir /mnt/nix
sudo mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos-fs /mnt/nix

sudo mkdir /mnt/persist
sudo mount -o subvol=persist,compress=zstd,noatime /dev/disk/by-label/nixos-fs /mnt/persist

sudo mkdir -p /mnt/var/log
sudo mount -o subvol=log,compress=zstd,noatime /dev/disk/by-label/nixos-fs /mnt/var/log

sudo mkdir /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
```

## Decryption:
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-label/nixos
```
