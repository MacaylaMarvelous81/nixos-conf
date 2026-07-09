{
  nixos-raspberrypi ? import (fetchTarball {
    url = "https://github.com/nvmd/nixos-raspberrypi/archive/refs/tags/v1.20260707.1.tar.gz";
    sha256 = "sha256:1cz6f6r3xpd8m0b5walqdn64vsc12a8jgfmz8vga9lkgrgw5nsjb";
  }),
}:
nixos-raspberrypi.lib.nixosSystem {
  modules = [
    ./configuration.nix
    ({ nixos-raspberrypi, ... }: {
      imports = with nixos-raspberrypi.nixosModules; [
        raspberry-pi-5.base
      ];

      boot.loader.raspberry-pi.bootloader = "kernel";

      nixpkgs.hostPlatform = "aarch64-linux";

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
          options = [
            "x-initrd.mount"
            "noatime"
          ];
        };
        "/boot/firmware" = {
          device = "/dev/disk/by-label/FIRMWARE";
          fsType = "vfat";
          options = [
            "noatime"
            "noauto"
            "x-systemd.automount"
            "x-systemd.idle-timeout=1min"
          ];
        };
      };
    })
  ];
}
