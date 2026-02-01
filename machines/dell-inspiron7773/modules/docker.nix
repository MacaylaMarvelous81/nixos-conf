{ config, lib, ... }:
let
  cfg = config.machine.docker;
in {
  options.machine.docker = {
    enable = lib.mkEnableOption "management of docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
