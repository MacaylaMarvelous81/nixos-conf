{ config, lib, ... }:
let
  cfg = config.machine.graphical-session;
in {
  options.machine.graphical-session = {
    enable = lib.mkEnableOption "dell-insprion7773 graphical session config";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
