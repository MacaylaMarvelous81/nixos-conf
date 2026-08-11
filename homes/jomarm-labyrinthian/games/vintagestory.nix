{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.games.vintagestory;
in
{
  options.homes.jomarm-labyrinthian.games.vintagestory = {
    enable = lib.options.mkEnableOption "User configuration for Vintage Story";
    package = lib.options.mkPackageOption pkgs "vintagestory" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.sessionVariables.VINTAGE_STORY = "${cfg.package}/share/vintagestory";
  };
}
