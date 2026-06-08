{ config, lib, ... }:
let
  cfg = config.machine.graphics;
in
{
  options.machine.graphics = {
    enable = lib.mkEnableOption "dell-inspiron7773 graphics module";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    hardware.nvidia.branch = "legacy_580";
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.open = false;
    hardware.nvidia.prime = {
      # sync.enable = true;
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
    hardware.nvidia.powerManagement.enable = true;
  };
}
