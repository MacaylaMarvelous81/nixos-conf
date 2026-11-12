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
      # git-http-backend refuses to interact with repositories not owned by the
      # user it is run as unless that user has marked it as "safe" in its git
      # config, and I personally want repositories to be owned by their maintainers
      # and for the cgit user not to have a git config
      gitHttpBackend.enable = false;
      nginx.virtualHost = cfg.domain;
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = cfg.domain;
    };

    security.acme.certs."${cfg.domain}".group = config.services.nginx.group;
  };
}
