{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.worlds.labyrinthia.graphical-session;
  themepkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      BackgroundPlaceholder = "";
      Background = pkgs.fetchurl {
        url = "https://images.steamusercontent.com/ugc/1701780623175527143/5BCE317B403D24A26A56EA0C42B516662E5C8896/";
        hash = "";
      };
    };
    embeddedTheme = "hyprland_kath";
  };
in
{
  options.worlds.labyrinthia.graphical-session = {
    enable = lib.mkEnableOption "Default graphical sessions for Labyrinthia";
  };

  config = lib.mkIf cfg.enable (
    lib.mkDefault {
      programs.niri.enable = true;

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "${themepkg}/share/sddm/themes/sddm-astronaut-theme";
        extraPackages = [ themepkg ];
      };
    }
  );
}
