{ config, pkgs, lib, ... }:
let
  cfg = config.machine.user;
in {
  options.machine.user = {
    enable = lib.mkEnableOption "dell-inspiron7773 user module";
    sources = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.path;
      description = "An attrset of the pinned sources to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.jomarm = {
      isNormalUser = true;
      description = "Jomar Milan";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
    };

    home-manager.users.jomarm = { ... }: {
      imports = [
        ../../../home-manager/modules

        (import ../../../home-manager/inputs.nix { inherit (cfg) sources; })
      ];

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        (limo.override { withUnrar = true; })
        dragon-drop
      ];

      home.shellAliases = {
        img = "${ pkgs.chafa }/bin/chafa";
      };

      usermod.email.enable = true;
      usermod.gpg.enable = true;
      usermod.neovim.enable = true;
      usermod.git.enable = true;
      usermod.shell.enable = true;
      usermod.ssh.enable = true;
      usermod.aerc.enable = true;
      usermod.offlineimap.enable = true;
      usermod.niri.enable = true;
      usermod.noctalia-shell.enable = true;
      usermod.stylix.enable = true;
      usermod.firefox.enable = true;
      usermod.secrets.enable = true;
      usermod.term.enable = true;
      usermod.portty.enable = true;
      usermod.hydrus.enable = true;
      usermod.atool.enable = true;

      programs.noctalia-shell.package = pkgs.callPackage "${ cfg.sources.noctalia-shell }/nix/package.nix" {};
      programs.niri.settings = {
        debug = {
          render-drm-device = "/dev/dri/card1";
        };
      };     

      xdg.portal.enable = true;

      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.dekstop";
          "x-scheme-handler/https" = "firefox.desktop";
          "application/x-extension-html" = "firefox.desktop";
        };
      };
    };
  };
}
