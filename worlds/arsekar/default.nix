{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.worlds.arsekar;
in
{
  imports = [
    ./git-server.nix
    ./matrix.nix
    ./www.nix
    ./xmpp.nix
  ];

  options.worlds.arsekar = {
    enable = lib.options.mkEnableOption "Arsekar NixOS config";
    domain = lib.options.mkOption {
      type = lib.types.str;
      default = "pyrodax.com";
      description = "Domain name that other services will base default subdomains from";
    };
  };

  config = lib.mkIf cfg.enable {
    worlds.arsekar = {
      git-server.enable = lib.mkDefault true;
      matrix.enable = lib.mkDefault true;
      www.enable = lib.mkDefault true;
      xmpp.enable = lib.mkDefault true;
    };

    networking.hostName = "arsekar";
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.nginx.enable = true;
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowGroups = [ "users" ];
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "jomarm@pyrodax.com";
      defaults.webroot = "/var/lib/acme/acme-challenge/";
    };
  };
}
