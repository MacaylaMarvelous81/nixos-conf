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
        (limo.override {
          withUnrar = true;
          # nixpkgs: 0b9ba739bcd2048da57b88899a390c372c500608 (libloot: fix build)
          libloot = pkgs.libloot.overrideAttrs (prevAttrs: {
            passthru = (prevAttrs.passthru or {}) // {
              yaml-cpp-src = pkgs.fetchFromGitHub {
                owner = "loot";
                repo = "yaml-cpp";
                tag = "0.8.0+merge-key-support.2";

                postFetch = ''
                  sed -e 'li #include <cstdint>' -i "$out/src/emitterurils.cpp"
                '';

                hash = "sha256-5xbqOI4L3XCqx+4k6IcZUwOdHAfbBy7nZgRKGkRJabQ=";
              };
            };
          });
        })
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
