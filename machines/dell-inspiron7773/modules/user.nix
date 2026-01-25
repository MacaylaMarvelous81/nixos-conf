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

    home-manager.users.jomarm = { config, ... }: {
      imports = [
        ../../../home-manager/modules

        (import ../../../home-manager/inputs.nix { inherit (cfg) sources; })
      ];

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        (limo.override { withUnrar = true; })
        dragon-drop
        aseprite
        (buildFHSEnv {
          # bit of a mess of an adhoc wrapper...
          name = "stellaris-gog-unpacked-env";
          includeClosures = true;
          # Based on steam env
          targetPkgs = pkgs: with pkgs; [
            bash
            coreutils
            file
            lsb-release
            pciutils
            glibc_multi.bin
            usbutils
            xdg-utils
            xz
            zenity
          ];
          # Based on steam env, + nss and nspr
          multiPkgs = pkgs: with pkgs; [
            glibc
            libxcrypt
            libGL
            libdrm
            libgbm
            udev
            libudev0-shim
            libva
            vulkan-loader
            networkmanager
            libcap
            nss
            nspr
          ];
          extraInstallCommands = ''
            mkdir -p $out/share/applications
            cat > $out/share/applications/gog_com-Stellaris_1.desktop <<EOF
            [Desktop Entry]
            Encoding=UTF-8
            Value=1.0
            Type=Application
            Name=Stellaris
            GenericName=Stellaris
            Comment=Stellaris
            Icon=${ config.home.homeDirectory }/GOG Games/Stellaris/support/icon.png
            Exec="$out/bin/stellaris-gog-unpacked-env" ""
            Categories=Game;
            Path=${ config.home.homeDirectory }/GOG Games/Stellaris
            EOF
          '';
          runScript = "\"${ config.home.homeDirectory }\"/GOG\\ Games/Stellaris/start.sh";
        })
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
