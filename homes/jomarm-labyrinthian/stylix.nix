{
  options,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.stylix;
in
{
  options.homes.jomarm-labyrinthian.stylix = {
    enable = lib.mkEnableOption "User home-manager stylix configuration";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = builtins.hasAttr "stylix" options;
            message = "stylix module requires stylix";
          }
        ];

        fonts.fontconfig.enable = true;
        home.pointerCursor.enable = true;
      }
      (lib.optionalAttrs (builtins.hasAttr "stylix" options) {
        stylix = {
          enable = true;

          image = pkgs.fetchurl {
            url = "https://images.steamusercontent.com/ugc/1701780623175527143/5BCE317B403D24A26A56EA0C42B516662E5C8896/";
            hash = "sha256-Br0nOQkeLmSfKyrzCqMa1kwsxz2xGm1ILC1hV4wfhEQ=";
          };
          polarity = "dark";

          base16Scheme = "${pkgs.base16-schemes}/share/themes/silk-dark.yaml";

          cursor = {
            package = pkgs.scribble-scribble-scribble-cursor;
            name = "scribble-scribble-scribble-cursor";
            size = 24;
          };

          icons = {
            enable = true;
            package = pkgs.papirus-icon-theme;
            light = "Papirus-Light";
            dark = "Papirus-Dark";
          };

          fonts = {
            sansSerif = {
              package = pkgs.atkinson-hyperlegible;
              name = "Atkinson Hyperlegible";
            };
            monospace = {
              package = pkgs.nerd-fonts._0xproto;
              name = "0xProto Nerd Font";
            };
          };

          opacity.terminal = 0.8;

          targets.qt.standardDialogs = if config.xdg.portal.enable then "xdgdesktopportal" else "default";
        };
      })
    ]
  );
}
