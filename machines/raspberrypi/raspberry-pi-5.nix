{
  nixos-raspberrypi ? import (fetchTarball {
    url = "https://github.com/nvmd/nixos-raspberrypi/archive/refs/tags/v1.20260801.0.tar.gz";
    sha256 = "sha256:08xq347rgbq95qphfgcwic7hdzabm8xpkd08ban2598cwnawwgr9";
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
