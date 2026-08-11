{ config, lib, ... }:
let
  cfg = config.worlds.arsekar.www;
in
{
  options.worlds.arsekar.www = {
    enable = lib.options.mkEnableOption "Website configuration";
    domain = lib.options.mkOption {
      type = lib.types.str;
      default = config.worlds.arsekar.domain;
      description = "Domain name to use for this service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        forceSSL = true;
        useACMEHost = cfg.domain;
        root = "/srv/www";
      };
      "openpgpkey.${cfg.domain}" = {
        forceSSL = true;
        useACMEHost = cfg.domain;
        locations."/.well-known/openpgpkey/" = {
          root = "/srv/www";
          extraConfig = ''
            add_header Access-Control-Allow-Origin *;
          '';
        };
      };
    };

    security.acme.certs."${cfg.domain}" = {
      group = config.services.nginx.group;
      extraDomainNames = [ "openpgpkey.${cfg.domain}" ];
    };
  };
}
