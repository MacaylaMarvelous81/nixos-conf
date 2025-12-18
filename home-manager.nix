{ ... }:
let
  sources = import ./npins;
  home-manager = sources.home-manager;
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.jomarm = { ... }: {
    imports = [ ./home-manager/home.nix ];
  };
}
