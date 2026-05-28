{ pkgs, nixos-raspberrypi, ... }:
{
  imports = with nixos-raspberrypi.nixosModules; [
    nixos-raspberrypi.lib.inject-overlays
    trusted-nix-caches
    nixpkgs-rpi
    nixos-raspberrypi.lib.inject-overlays-global

    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k

    ../../pinning.nix
    ../../modules
  ];

  networking.hostName = "raspberrypi";
}
