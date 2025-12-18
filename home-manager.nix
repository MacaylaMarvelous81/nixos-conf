{ ... }:
{
  home-manager.users.jomarm = { ... }: {
    imports = [ ./home-manager/home.nix ];
  };
}
