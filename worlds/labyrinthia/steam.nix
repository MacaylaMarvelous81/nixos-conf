{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.worlds.labyrinthia.steam;
in
{
  options.worlds.labyrinthia.steam = {
    enable = lib.mkEnableOption "Default Steam options for Labyrinthia";
  };

  config = lib.mkIf cfg.enable (
    lib.mkDefault {
      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraArgs = "-system-composer";
        };
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
    }
  );
}
