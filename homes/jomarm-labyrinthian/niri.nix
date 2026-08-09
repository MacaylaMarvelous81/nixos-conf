{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.niri;
in
{
  options.homes.jomarm-labyrinthian.niri = {
    enable = lib.mkEnableOption "User configuration for Niri window manager";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.niri = {
      enable = true;
      settings = {
        binds = {
          "Mod+Left".focus-column-left = { };
          "Mod+Right".focus-column-right = { };
          "Mod+Down".focus-window-or-workspace-down = { };
          "Mod+Up".focus-window-or-workspace-up = { };

          "Mod+Ctrl+Left".move-column-left = { };
          "Mod+Ctrl+Right".move-column-right = { };
          "Mod+Ctrl+Down".move-window-down-or-to-workspace-down = { };
          "Mod+Ctrl+Up".move-window-up-or-to-workspace-up = { };

          "Mod+Shift+Left".focus-monitor-left = { };
          "Mod+Shift+Right".focus-monitor-right = { };
          "Mod+Shift+Down".focus-monitor-down = { };
          "Mod+Shift+Up".focus-monitor-up = { };

          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
          "Mod+Shift+Ctrl+Down".move-window-to-monitor-down = { };
          "Mod+Shift+Ctrl+Up".move-window-to-monitor-up = { };

          "Mod+Alt+Left".consume-or-expel-window-left = { };
          "Mod+Alt+Right".consume-or-expel-window-right = { };

          "Mod+F".maximize-column = { };
          "Mod+Ctrl+F".maximize-window-to-edges = { };
          "Mod+Shift+F".fullscreen-window = { };

          "Mod+D".toggle-window-floating = { };
          "Mod+Shift+D".switch-focus-between-floating-and-tiling = { };

          "Mod+S".spawn = [
            "${pkgs.niri-sidebar}/bin/niri-sidebar"
            "toggle-window"
          ];
          "Mod+Shift+S".spawn = [
            "${pkgs.niri-sidebar}/bin/niri-sidebar"
            "toggle-visibility"
          ];
          "Mod+Ctrl+S".spawn = [
            "${pkgs.niri-sidebar}/bin/niri-sidebar"
            "flip"
          ];
          "Mod+Alt+S".spawn = [
            "${pkgs.niri-sidebar}/bin/niri-sidebar"
            "reorder"
          ];

          "Mod+C".toggle-column-tabbed-display = { };

          "Mod+Home".focus-column-first = { };
          "Mod+End".focus-column-last = { };

          "Mod+Ctrl+Home".move-column-to-first = { };
          "Mod+Ctrl+End".move-column-to-last = { };

          "Mod+Ctrl+Alt+Delete".quit = { };

          "Mod+R".switch-preset-column-width = { };
          "Mod+V".toggle-overview = { };
          "Mod+Q".close-window = { };

          "Mod+Escape" = {
            _props.allow-inhibiting = false;
            toggle-keyboard-shortcuts-inhibit = { };
          };

          "Print".screenshot._props = {
            show-pointer = false;
          };
          "Shift+Print".screenshot-screen._props = {
            show-pointer = false;
          };
          "Alt+Print".screenshot-window = { };

          "XF86AudioRaiseVolume" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
          };
          "XF86AudioLowerVolume" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
          };
          "Shift+XF86AudioRaiseVolume" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "10%+"
            ];
          };
          "Shift+XF86AudioLowerVolume" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "10%-"
            ];
          };
          "XF86AudioMute" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
          };
          "XF86AudioMicMute" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];
          };
          "XF86MonBrightnessUp" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.brightnessctl}/bin/brightnessctl"
              "--class=backlight"
              "set"
              "1%+"
            ];
          };
          "XF86MonBrightnessDown" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.brightnessctl}/bin/brightnessctl"
              "--class=backlight"
              "set"
              "1%-"
            ];
          };
          "Shift+XF86MonBrightnessUp" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.brightnessctl}/bin/brightnessctl"
              "--class=backlight"
              "set"
              "10%+"
            ];
          };
          "Shift+XF86MonBrightnessDown" = {
            _props.allow-when-locked = true;
            spawn = [
              "${pkgs.brightnessctl}/bin/brightnessctl"
              "--class=backlight"
              "set"
              "10%-"
            ];
          };

          "Mod+E".spawn = [ "${pkgs.lxqt.pcmanfm-qt}/bin/pcmanfm-qt" ];
          "Mod+T".spawn = [ "${config.programs.foot.package}/bin/foot" ];
        };

        input = {
          touch.map-to-output = "eDP-1";

          mouse = {
            accel-speed = 0.0;
            accel-profile = "adaptive";
            scroll-factor = 0.6;
          };
        };

        layout = {
          gaps = 8;
          always-center-single-column = { };
          border.width = 2;
          shadow.offset._props = {
            x = 0;
            y = 5;
          };
        };

        hotkey-overlay.skip-at-startup = { };
        prefer-no-csd = { };

        _children = [
          {
            window-rule._children = [
              {
                geometry-corner-radius = [
                  8
                  8
                  8
                  8
                ];
              }
              { clip-to-geometry = true; }
            ];
          }
          {
            window-rule._children = [
              {
                match._props = {
                  app-id = "steam";
                  title = "^notificationtoasts_\\d+_desktop$";
                };
              }
              { open-focused = false; }
              { baba-is-float = true; }
              {
                default-floating-position._props = {
                  relative-to = "bottom-right";
                  x = 10;
                  y = 10;
                };
              }
            ];
          }
        ];
      };
    };

    # Similar to the definition from <home-manager/modules/services/window-managers/niri.nix>,
    # but uses lib.addContextFrom together with lib.trim because lib.trim drops string context,
    # causing derivations referenced in the resulting configuration to be eligible for garbage
    # collection.
    #
    # https://github.com/NixOS/nix/issues/2547
    xdg.configFile."niri/config.kdl" = lib.mkOverride 99 (
      let
        toKDL = lib.hm.generators.toKDL {
          escapeBackslashes = true;
          escapeTabs = true;
        };
        configSettings = toKDL config.wayland.windowManager.niri.settings;
        settings = lib.addContextFrom configSettings (lib.trim configSettings);
        configLines = lib.concatStringsSep "\n" (
          lib.filter (line: line != "") [
            config.wayland.windowManager.niri.extraConfigEarly
            settings
            config.wayland.windowManager.niri.extraConfig
          ]
        );
      in
      lib.mkIf (configLines != "") {
        source = pkgs.writeTextFile {
          name = "niri-config.kdl";
          text = ''
            // Automatically generated by home-manager from `homes.jomarm-labyrinthian.niri`
            ${configLines}
          '';
          checkPhase = lib.optionalString config.wayland.windowManager.niri.checkConfig ''
            ${lib.getExe config.wayland.windowManager.niri.package} validate --config "$target"
          '';
        };
      }
    );
  };
}
