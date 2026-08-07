{ config, lib, ... }:
let
  cfg = config.worlds.arsekar.xmpp;
in
{
  options.worlds.arsekar.xmpp = {
    enable = lib.options.mkEnableOption "XMPP server config";
    domain = lib.options.mkOption {
      type = lib.types.str;
      default = config.worlds.arsekar.domain;
      description = "Domain name for xmpp server name";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      5000
      5222
      5269
      5281
    ];

    services.prosody = {
      enable = true;
      admins = [ "jomarm@pyrodax.com" ];
      ssl.cert = "/var/lib/prosody/fullchain.pem";
      ssl.key = "/var/lib/prosody/key.pem";
      virtualHosts."${cfg.domain}" = {
        enabled = true;
        domain = cfg.domain;
        ssl.cert = "/var/lib/prosody/fullchain.pem";
        ssl.key = "/var/lib/prosody/key.pem";
      };
      muc = [ { domain = "conference.${cfg.domain}"; } ];
      httpFileShare.domain = "upload.${cfg.domain}";
    };

    security.acme.certs."${cfg.domain}" = {
      extraDomainNames = [
        "conference.${cfg.domain}"
        "upload.${cfg.domain}"
      ];
      postRun = ''
        install -o prosody -g prosody fullchain.pem /var/lib/prosody/fullchain.pem
        install -o prosody -g prosody key.pem /var/lib/prosody/key.pem
      '';
    };
  };
}
