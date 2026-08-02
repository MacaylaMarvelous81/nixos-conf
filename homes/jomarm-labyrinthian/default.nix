{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian;
in
{
  imports = [
    ./hydrus
    ./web-browser
  ];

  options.homes.jomarm-labyrinthian = {
    enable = lib.mkEnableOption "home-manager configuration for Jomar Milan";
  };

  config = lib.mkIf cfg.enable {
    homes.jomarm-labyrinthian = {
      hydrus.enable = lib.mkDefault true;
      web-browser.enable = lib.mkDefault true;
    };

    accounts.email = {
      certificatesFile = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      accounts."jomarm" = {
        accounts.email.accounts = {
          "jomarm" = {
            address = "jomarm@pyrodax.com";
            gpg = {
              encryptByDefault = true;
              key = "6AC46A6F9A5618D8";
              signByDefault = true;
            };
            imap = {
              host = "imap.purelymail.com";
              port = 993;
              tls.enable = true;
            };
            smtp = {
              host = "smtp.purelymail.com";
              port = 465;
              tls.enable = true;
            };
            userName = "jomarm@pyrodax.com";
            # passwordCommand = "cat ${config.home.homeDirectory}/.secrets/jomarm@pyrodax.com";
            primary = true;
            realName = "Jomar Milan";

            aerc = {
              enable = true;
              extraAccounts = {
                pgp-opportunistic-encrypt = true;
                pgp-auto-sign = true;
                signature-file = pkgs.writeText "jomarm-email-sig" ''
                  Jomar Milan

                  If possible, please sign and encrypt your emails with OpenPGP. My key is
                  accessible via the WKD protocol, or at https://pyrodax.com/key.gpg with the
                  following fingerprint:

                  F954 C5C9 5AE7 A312 183D  A76C 6AC4 6A6F 9A56 18D8
                '';
              };
              extraBinds = {
                view.ga = ":pipe -mb ${config.programs.git.package} am -3<Enter>";
              };
            };
          };
        };
      };
    };

    home.packages = with pkgs; [
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
      deadbeef
      dino
      jetbrains.idea
      jetbrains.rider
      kdePackages.ark
      kdePackages.okular
      krita
      (limo.override { withUnrar = true; })
      nixtamal
      seahorse
    ];

    programs.aerc = {
      enable = true;
      extraConfig = {
        general = {
          # Necessary due to a documented home-manager limitation. Safe because password command option is used instead
          # of storing the password directly in the configuration file.
          unsafe-accounts-conf = true;
        };
        filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "!html";
        };
      };
      extraBinds = builtins.readFile "${config.programs.aerc.package}/share/aerc/binds.conf";
    };
    programs.calibre.enable = true;
    programs.feh.enable = true;
    programs.freetube.enable = true;
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          source = ./gpg-keychain/jomarm-at-pyrodax.com.asc;
          trust = "ultimate";
        }
      ];
    };
    programs.prismlauncher.enable = true;
    programs.qalculate = {
      enable = true;
      package = pkgs.qalculate-qt;
    };

    services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      enableExtraSocket = true;
      enableZshIntegration = true;
      pinentry.package = pkgs.pinentry-qt;
    };
    services.udiskie.enable = true;

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = [ "librewolf.desktop" ];
        "x-scheme-handler/http" = [ "librewolf.dekstop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "application/x-extension-html" = [ "librewolf.desktop" ];

        "text/plain" = [ "neovide.desktop" ];

        "inode/directory" = [ "pcmanfm-qt.desktop" ];
        "inode/mount-point" = [ "pcmanfm-qt.desktop" ];
      };

      defaultApplicationPackages = [ config.programs.feh.package ];
    };
  };
}
