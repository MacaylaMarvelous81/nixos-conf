{ config, pkgs, lib, ... }:
let
  cfg = config.osusermod.steam;
in {
  options.osusermod.steam = {
    enable = lib.mkEnableOption "nixos steam configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraArgs = "-system-composer";
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
