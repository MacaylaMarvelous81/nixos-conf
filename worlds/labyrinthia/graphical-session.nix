{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.worlds.labyrinthia.graphical-session;
  # themepkg = pkgs.sddm-astronaut.override {
  #   themeConfig = {
  #     BackgroundPlaceholder = "";
  #     Background = pkgs.fetchurl {
  #       url = "https://images.steamusercontent.com/ugc/1701780623175527143/5BCE317B403D24A26A56EA0C42B516662E5C8896/";
  #       hash = "sha256-Br0nOQkeLmSfKyrzCqMa1kwsxz2xGm1ILC1hV4wfhEQ=";
  #     };
  #   };
  #   embeddedTheme = "hyprland_kath";
  # };
  themepkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "qylock-sddm-themes";
    version = "0-unstable-2026-08-05";

    src = pkgs.fetchFromGitHub {
      owner = "Darkkal44";
      repo = "qylock";
      rev = "519310704a917733d6afeb597f27b3845518da51";
      hash = "sha256-++Tykq/IJLSWg7ivS3cT3MPEdjay2vWwYJR0tZ2r1NI=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/sddm/themes
      cp -r themes/. $out/share/sddm/themes/

      runHook postInstall
    '';
  };
in
{
  options.worlds.labyrinthia.graphical-session = {
    enable = lib.mkEnableOption "Default graphical sessions for Labyrinthia";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${themepkg}/share/sddm/themes/pixel-waterfall";
      extraPackages = [
        themepkg
        pkgs.qt6.qt5compat
        pkgs.qt6.qtmultimedia
        pkgs.qt6.qtsvg
      ];
    };
  };
}
