{
  sources ? import ./tamal { },
  nixosEval ? import "${sources.nixpkgs}/nixos/lib/eval-config.nix",
}:
nixosEval {
  modules = [ ./configuration.nix ];
}
