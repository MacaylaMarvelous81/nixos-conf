{
  sources ? import ./nix/sources.nix,
  nixos-raspberrypi ? import sources.nixos-raspberrypi,
  nixosEval ? import "${sources.nixpkgs}/nixos/lib/eval-config.nix",
}:
nixosEval {
  specialArgs = { inherit nixos-raspberrypi; };
  modules = [ ./configuration.nix ];
}
