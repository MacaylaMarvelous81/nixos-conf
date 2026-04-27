{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.machine.graphical-session;
  themepkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      BackgroundPlaceholder = "";
      Background = "${../../../home-manager/home-manager-private}/2533132599-1-screenshot.png";
    };
    embeddedTheme = "hyprland_kath";
  };
in
{
  options.machine.graphical-session = {
    enable = lib.mkEnableOption "dell-insprion7773 graphical session config";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${themepkg}/share/sddm/themes/sddm-astronaut-theme";
      extraPackages = [ themepkg ];
    };
  };
}
