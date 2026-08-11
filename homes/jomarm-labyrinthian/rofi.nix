{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.rofi;
in
{
  options.homes.jomarm-labyrinthian.rofi = {
    enable = lib.options.mkEnableOption "User configuration for Rofi application launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          window = {
            border = 2;
            border-radius = 12;
          };
          listview = {
            border-radius = 10;
            border = 2;
            padding = 20;
            margin = mkLiteral "20px 30px 30px 30px";
            spacing = mkLiteral "0.3em";
          };
          element = {
            spacing = mkLiteral "0.5em";
            children = map mkLiteral [
              "element-icon"
              "element-text"
            ];
          };
        };
    };

    wayland.windowManager.niri = lib.mkIf config.wayland.windowManager.niri.enable {
      settings.binds = {
        "Mod+Space".spawn = [
          "${config.programs.rofi.package}/bin/rofi"
          "-show"
          "drun"
        ];
        "Mod+L".spawn = [
          "${config.programs.rofi.package}/bin/rofi"
          "-show"
          "power-menu"
          "-modi"
          "power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu"
        ];
      };
    };
  };
}
