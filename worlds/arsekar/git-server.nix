{
  config,
  lib,
  ...
}:
let
  cfg = config.worlds.arsekar.git-server;
in
{
  options.worlds.arsekar.git-server = {
    enable = lib.options.mkEnableOption "NixOS git server configuration";
    domain = lib.options.mkOption {
      type = lib.types.str;
      default = "git.${config.worlds.arsekar.domain}";
      description = "Domain name to use for this service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cgit."${cfg.domain}" = {
      enable = true;
      scanPath = "/srv/git";
      gitHttpBackend = {
        enable = true;
        checkExportOkFiles = false;
      };
      nginx.virtualHost = cfg.domain;
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = cfg.domain;
    };

    security.acme.certs."${cfg.domain}".group = config.services.nginx.group;
  };
}
