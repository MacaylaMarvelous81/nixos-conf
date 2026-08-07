{ config, lib, ... }:
let
  cfg = config.worlds.arsekar.matrix;
in
{
  options.worlds.arsekar.matrix = {
    enable = lib.options.mkEnableOption "Matrix server configuration";
    name = lib.options.mkOption {
      type = lib.types.str;
      default = config.worlds.arsekar.domain;
      description = "Domain name used for Matrix server name";
    };
    domain = lib.options.mkOption {
      type = lib.types.str;
      default = "matrix.${cfg.name}";
      description = "Domain name for Matrix clients and servers to communicate with";
    };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-continuwuity = {
      enable = true;
      settings = {
        global = {
          server_name = cfg.name;
          unix_socket_path = "/run/continuwuity/continuwuity.sock";
          well_known = {
            client = "https://${cfg.domain}";
            server = "${cfg.domain}:443";
          };
        };
      };
    };

    services.nginx = {
      virtualHosts."${cfg.name}".locations."/.well-known/matrix/" = {
        proxyPass = "http://unix:/run/continuwuity/continuwuity.sock:/.well-known/matrix/";
        recommendedProxySettings = true;
      };

      virtualHosts."${cfg.domain}" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
          {
            addr = "[::0]";
            port = 443;
            ssl = true;
          }
          {
            addr = "0.0.0.0";
            port = 8448;
            ssl = true;
          }
          {
            addr = "[::0]";
            port = 8448;
            ssl = true;
          }
        ];
        forceSSL = true;
        useACMEHost = cfg.domain;
        locations."/" = {
          proxyPass = "http://unix:/run/continuwuity/continuwuity.sock:$request_uri";
          recommendedProxySettings = true;
        };
        extraConfig = ''
          client_max_body_size 20M;
        '';
      };
    };

    security.acme.certs."${cfg.name}".group = config.services.nginx.group;
    security.acme.certs."${cfg.domain}".group = config.services.nginx.group;

    users.groups."${config.services.matrix-continuwuity.group}".members = [
      config.services.nginx.user
    ];
  };
}
