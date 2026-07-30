{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.machine.user;
in
{
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
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOfZ3GVOc4/hDqYzxlfg41y5MgtVD9WQxmN90QtHt4I jomarm@Jomars-MacBook-Pro.local"
      ];
    };

    home-manager.users.jomarm =
      {
        config,
        pkgs,
        erosanix,
        macaylamarvelous81-pkgs,
        wrappers,
        ...
      }:
      {
        imports = [
          ../../../home-manager/modules

          (import ../../../home-manager/inputs.nix { inherit (cfg) sources; })
        ];

        home.stateVersion = "24.11";

        usermod.unfree.pkgnames = [
          "aseprite"
          "idea"
          "rider"
          "SSEEdit"
        ];

        home.packages = with pkgs; [
          (buildFHSEnv {
            # bit of a mess of an adhoc wrapper...
            name = "stellaris-gog-unpacked-env";
            includeClosures = true;
            # Based on steam env
            targetPkgs =
              pkgs: with pkgs; [
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
            multiPkgs =
              pkgs: with pkgs; [
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
              Icon=${config.home.homeDirectory}/GOG Games/Stellaris/support/icon.png
              Exec="$out/bin/stellaris-gog-unpacked-env" ""
              Categories=Game;
              Path=${config.home.homeDirectory}/GOG Games/Stellaris
              EOF
            '';
            runScript = "\"${config.home.homeDirectory}\"/GOG\\ Games/Stellaris/start.sh";
          })
          (limo.override { withUnrar = true; })
          (aseprite.overrideAttrs (
            finalAttrs: prevAttrs: {
              postPatchHooks = [
                # Aseprite's desktop file requests for the application to be
                # executed with URIs, but then proceeds to fail finding files
                # by URI, while working correctly with file paths. Such is
                # the way of software, I guess.
                ''
                  substituteInPlace src/desktop/linux/aseprite.desktop \
                    --replace-fail 'Exec=aseprite %U' 'Exec=aseprite %F'
                ''
              ]
              ++ (prevAttrs.postPatchHooks or [ ]);
            }
          ))
          cinny-desktop
          dino
          dragon-drop
          erosanix.defaultNix.packages."${builtins.currentSystem}".mkwindowsapp-tools
          jetbrains.idea
          jetbrains.rider
          kdePackages.ark
          kdePackages.okular
          krita
          macaylamarvelous81-pkgs.sseedit
          nixtamal
          pijul
          seahorse
        ];

        home.shellAliases = {
          img = "${pkgs.chafa}/bin/chafa";
        };

        usermod.email.enable = true;
        usermod.gpg.enable = true;
        usermod.git.enable = true;
        usermod.shell.enable = true;
        usermod.ssh.enable = true;
        usermod.aerc.enable = true;
        usermod.offlineimap.enable = true;
        usermod.niri.enable = true;
        usermod.stylix.enable = true;
        usermod.firefox.enable = true;
        usermod.secrets.enable = true;
        usermod.term.enable = true;
        usermod.explorer.enable = true;
        usermod.hydrus.enable = true;
        usermod.atool.enable = true;
        usermod.wallpaper.enable = true;
        usermod.vintagestory.enable = true;
        usermod.rofi.enable = true;
        usermod.waybar.enable = true;
        usermod.neovim = {
          enable = true;
          neovide = true;
        };
        usermod.dunst.enable = true;

        programs.calibre.enable = true;
        programs.prismlauncher.enable = true;
        programs.obs-studio.enable = true;
        programs.qalculate = {
          enable = true;
          package = pkgs.qalculate-qt;
        };

        programs.feh.enable = true;

        # new default value in stateVersion 26.04
        gtk.gtk4.theme = lib.mkDefault null;

        services.udiskie.enable = true;

        xdg.portal.enable = true;

        xdg.mimeApps = {
          enable = true;

          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.dekstop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "application/x-extension-html" = [ "firefox.desktop" ];

            "text/plain" = [ "neovide.desktop" ];

            "inode/directory" = [ "pcmanfm-qt.desktop" ];
            "inode/mount-point" = [ "pcmanfm-qt.desktop" ];
          };
          defaultApplicationPackages = [ config.programs.feh.package ];
          #   ++ builtins.listToAttrs (
          #     map
          #       (name: {
          #         inherit name;
          #         value = [ "feh.desktop" ];
          #       })
          #       [
          #         "image/bmp"
          #         "image/gif"
          #         "image/jpeg"
          #         "image/jpg"
          #         "image/pjpeg"
          #         "image/png"
          #         "image/tiff"
          #         "image/webp"
          #         "image/x-bmp"
          #         "image/x-pcx"
          #         "image/x-png"
          #         "image/x-portable-anymap"
          #         "image/x-portable-bitmap"
          #         "image/x-portable/graymap"
          #         "image/x-portable-pixmap"
          #         "image/x-tga"
          #         "image/x-xbitmap"
          #         "image/heic"
          #       ]
          #   );
        };
      };
  };
}
