{
  options,
  config,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.statusbar;
in
{
  options.homes.jomarm-labyrinthian.statusbar = {
    enable = lib.options.mkEnableOption "User configuration for system status bar";
    accentTextColor = lib.options.mkOption {
      type = lib.types.str;
      default = "#df6124";
      description = "Accent text color for styling in the status bar.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.waybar = {
          enable = true;
          systemd.enable = true;
          settings = {
            bar = {
              layer = "top";
              position = "top";
              margin-top = 2;
              margin-left = 80;
              margin-bottom = 0;
              margin-right = 80;
              modules-left = [
                "tray"
                "custom/vertical-separator"
                "mpris"
                "custom/vertical-separator"
              ];
              modules-center = [
                "custom/vertical-separator"
                "custom/clock"
                "custom/vertical-separator"
              ];
              modules-right = [
                "custom/vertical-separator"
                "bluetooth"
                "custom/slash-separator"
                "network"
                "custom/slash-separator"
                "pulseaudio"
                "custom/slash-separator"
                "memory"
                "custom/slash-separator"
                "cpu"
              ];
              "custom/clock" = {
                exec = "date +'%H:%M %p - %A, %b %d' | tr '[:upper:]' '[:lower:]'";
                interval = 60;
                tooltip = false;
              };
              "custom/slash-separator" = {
                # nf-md-slash_forward
                format = "󰿟";
                tooltip = false;
              };
              "custom/vertical-separator" = {
                # nf-md-dots_vertical
                format = "󰇙";
                tooltip = false;
              };
              bluetooth = {
                justify = "center";
                format = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>bt</span> {status} {num_connections}";
                format-disabled = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>bt</span> {status}";
                format-connected = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>bt</span> con {num_connections}";
                tooltip-format = "Devices connected: {num_connections}";
              };
              cpu = {
                interval = 10;
                format = "<span weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>cpu</span> {usage:02}%";
                states = {
                  warning = 50;
                  critical = 80;
                };
              };
              memory = {
                interval = 2;
                format = "<span weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>mem</span> {percentage:02}%";
                states = {
                  warning = 50;
                  critical = 80;
                };
              };
              mpris = {
                # nf-cod-music
                format = " {dynamic}";
                format-paused = "<span color='grey'>{status_icon} {dynamic}</span>";
                title-len = 20;
                dynamic-order = [
                  "artist"
                  "title"
                ];
                tooltip-format = "{player} ({status}):\n{artist} - {title}";
                status-icons = {
                  # nf-md-music_off
                  paused = "󰝛";
                };
              };
              network = {
                format-icons = [
                  # nf-md-wifi_strength_outline
                  "󰤯"
                  # nf-md-wifi_strength_1
                  "󰤟"
                  # nf-md-wifi_strength_2
                  "󰤢"
                  # nf-md-wifi_strength_3
                  "󰤥"
                  # nf-md-wifi_strength_4
                  "󰤨"
                ];
                format = "{icon}";
                format-wifi = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>net</span> {signalStrength}%";
                format-ethernet = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>net</span> on";
                # nf-md-wifi_strength_off_outline
                format-disconnected = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>net</span> off 󰤮";
                tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
                tooltip-format-ethernet = "⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
                tooltip-format-disconnected = "Disconnected";
                interval = 3;
                spacing = 1;
              };
              pulseaudio = {
                justify = "center";
                format = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>vol</span> {volume}%";
                tooltip-format = "Playing at {volume}%";
                scroll-step = 5;
                format-muted = "<span style='italic' weight='900' color='${config.homes.jomarm-labyrinthian.statusbar.accentTextColor}'>vol</span> muted";
                format-icons = {
                  # nf-fa-headphones
                  headphone = "";
                  default = [
                    # nf-fa-volume_off
                    ""
                    # nf-fa-volume_down
                    ""
                    # nf-fa-volume_high
                    ""
                  ];
                };
                states = {
                  warning = 50;
                  critical = 10;
                };
              };
              tray = {
                icon-size = 14;
                spacing = 0;
              };
            };
          };
          style = builtins.readFile ./style.css;
        };
      }
      (lib.optionalAttrs (builtins.hasAttr "stylix" options) {
        homes.jomarm-labyrinthian.statusbar.accentTextColor = lib.mkIf config.stylix.enable config.lib.stylix.colors.withHashtag.base08;
        stylix = lib.mkIf config.stylix.enable {
          targets.waybar.addCss = false;
        };
      })
    ]
  );
}
