{
  config,
  lib,
  ...
}:
let
  cfg = config.worlds.labyrinthia;
in
{
  imports = [
    ./steam.nix
    ./graphical-session.nix
  ];

  options.worlds.labyrinthia = {
    enable = lib.mkEnableOption "Labyrinthia NixOS configuration";
  };

  config = lib.mkIf cfg.enable (
    lib.mkDefault {
      worlds.labyrinthia = {
        steam.enable = true;
        graphical-session.enable = true;
      };

      programs.niri.enable = true;

      networking.hostName = "labyrinthia";
      networking.networkmanager.enable = true;

      nix.settings.trusted-users = [ "@wheel" ];

      services.blueman.enable = true;
      services.udisks2.enable = true;
    }
  );
}
