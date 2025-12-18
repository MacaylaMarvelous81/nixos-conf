{ ... }:
let
  sources = import ./npins;
in {
  # https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
  nix.channel.enable = false;
  nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  environment.etc = {
    "nixos/nixpkgs".source = sources.nixos;
  };
}
