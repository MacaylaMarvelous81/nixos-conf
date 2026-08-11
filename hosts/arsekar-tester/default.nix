{
  nixosEval ? import <nixpkgs/nixos/lib/eval-config.nix>,
}:
nixosEval {
  modules = [ ./configuration.nix ];
}
