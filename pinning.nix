{ config, lib, ... }:
let
  cfg = config.pinning;
in {
  options.pinning = {
    nixpkgs = lib.mkOption {
      description = "The path to the nixpkgs version to pin at";
    };
  };

  config = {
    # https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
    nix.channel.enable = false;
    nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];

    environment.etc = {
      "nixos/nixpkgs".source = cfg.nixpkgs;
    };
  };
}
