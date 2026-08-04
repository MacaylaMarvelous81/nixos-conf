{
  nixosEval ? import <nixpkgs/nixos/lib/eval-config.nix>,
}:
{
  dell-inspiron7773 = nixosEval {
    modules = [ ./dell-inspiron7773/configuration.nix ];
  };
}
