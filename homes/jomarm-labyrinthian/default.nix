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
    ./niri.nix
    ./rofi.nix
    ./stylix.nix
    ./text-editor.nix
    ./web-browser
  ];

  options.homes.jomarm-labyrinthian = {
    enable = lib.mkEnableOption "home-manager configuration for Jomar Milan";
  };

  config = lib.mkIf cfg.enable {
    homes.jomarm-labyrinthian = {
      hydrus.enable = lib.mkDefault true;
      niri.enable = lib.mkDefault true;
      rofi.enable = lib.mkDefault true;
      stylix.enable = lib.mkDefault true;
      text-editor.enable = lib.mkDefault true;
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

            offlineimap = {
              enable = true;
              # Assumption: jomarm-offlineimap-postsynchook available in nixpkgs package set
              postSyncHookCommand = "${pkgs.jomarm-offlineimap-postsynchook}/bin/jomarm-offlineimap-postsynchook ${config.accounts.email.maildirBasePath}/${
                config.accounts.email.accounts."jomarm".maildir.path
              }/INBOX";
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
      lxqt.pcmanfm-qt
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
    programs.bash.enable = true;
    programs.calibre.enable = true;
    programs.feh.enable = true;
    programs.foot.enable = true;
    programs.freetube.enable = true;
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      signing = {
        format = "openpgp";
        key = "F954C5C95AE7A312183DA76C6AC46A6F9A5618D8";
        signByDefault = true;
      };
      settings = {
        init.defaultBranch = "master";
        user = {
          name = "Jomar Milan";
          email = "jomarm@pyrodax.com";
        };
        sendemail = {
          smtpencryption = "ssl";
          smtpserver = "smtp.purelymail.com";
          smtpuser = "jomarm@pyrodax.com";
        };
        "diff \"json\"".textconv = "${pkgs.jq}/bin/jq .";
      };
    };
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          source = ./gpg-keychain/jomarm-at-pyrodax.com.asc;
          trust = "ultimate";
        }
      ];
    };
    programs.offlineimap.enable = true;
    programs.prismlauncher.enable = true;
    programs.qalculate = {
      enable = true;
      package = pkgs.qalculate-qt;
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlPath = "~/.ssh/master-%r@%n:%p";
      };
    };
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        bar = {
          layer = "top";
          position = "top";
          modules-left = [
            "niri/window"
            "mpris"
            "custom/spacer"
            "wireplumber"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "tray"
            "cpu"
            "custom/spacer"
            "memory"
            "custom/spacer"
            "disk"
            "custom/spacer"
            "network"
            "custom/spacer"
            "bluetooth"
          ];

          "niri/window" = {
            format = "> {title}";
          };
          mpris = {
            format = "<span color=\"#e3b872\">{player_icon}</span> {dynamic}";
            format-paused = "{status_icon} <i>{dynamic}</i>";
          };
          tray = {
            icon-size = 21;
            spacing = 10;
          };
          cpu = {
            format = " <span color=\"#e3b872\">cpu</span> {usage}";
            states = {
              warning = 80;
              critical = 95;
            };
          };
          memory = {
            format = "<span color=\"#e3b872\">mem</span> {used:0.1f}G/{total:0.1f}G";
          };
          disk = {
            format = "<span color=\"#e3b872\">dsk</span> {free}/{total}";
          };
          network = {
            format = "{ifname} ({ipaddr})";
            format-wifi = "{essid} ({ipaddr})";
          };
          bluetooth = {
            format = "<span color=\"#66c0f4\">bt</span> {status}";
            on-click = "${pkgs.blueman}/bin/blueman-manager";
          };
          "custom/spacer" = {
            format = " | ";
            tooltip = false;
          };
        };
      };
    };

    services.dunst = {
      enable = true;
      settings.global = lib.mkMerge [
        {
          mouse_left_click = "context,close_current";
          mouse_middle_click = "close_all";
          mouse_right_click = "close_current";
        }
        (lib.mkIf config.programs.rofi.enable {
          dmenu = "${config.programs.rofi.package}/bin/rofi -dmenu -p dunst";
        })
      ];
    };
    services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      enableExtraSocket = true;
      enableZshIntegration = true;
      pinentry.package = pkgs.pinentry-qt;
    };
    services.udiskie.enable = true;

    systemd.user.services.offlineimap = {
      Unit = {
        Description = "Offlineimap: a software to dispose your mailbox(es) as a local Maildir(s)";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${config.programs.offlineimap.package}/bin/offlineimap -u syslog -o -1";
        TimeoutStartSec = "120sec";
      };
    };
    systemd.user.services.wallpaper = {
      Unit = {
        Description = "Wallpaper rendered with linux-wallpaperengine";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        # Assumption: Wallpaper Engine is installed and workshop submissions are downloaded
        ExecStart = "\"${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine\" --silent --screen-root eDP-1 --bg 2533132599 --property cultistarcher=0 --property cultistarcher2=0 --property lunaticdevotee=0 --property lunaticdevotee2=0 --property blocks=0 --property stardustdragon1=1 --property shine=1";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    systemd.user.timers.offlineimap = {
      Unit = {
        Description = "offlineimap timer";
      };
      Timer = {
        Unit = "offlineimap.service";
        OnCalendar = "*:0/3";
        Persistent = "true";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

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
