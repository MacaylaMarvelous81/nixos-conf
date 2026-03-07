{
  config,
  lib,
  ...
}:
let
  cfg = config.machine.tablet;
in
{
  options.machine.tablet = {
    enable = lib.mkEnableOption "OpenTabletDriver tablet driver";
  };

  config = lib.mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;

    hardware.uinput.enable = true;
    boot.kernelModules = [ "uinput" ];
  };
}
