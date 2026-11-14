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
      settings = {
        clone-url = "https://git.pyrodax.com/$CGIT_REPO_URL";
        snapshots = "tar.gz tar.bz2 zip";

        source-filter = "${
          config.services.cgit."${cfg.domain}".package
        }/lib/cgit/filters/syntax-highlighting.py";
        about-filter = "${
          config.services.cgit."${cfg.domain}".package
        }/lib/cgit/filters/about-formatting.sh";

        "minetype.gif" = "image/gif";
        "mimetype.html" = "text/html";
        "mimetype.jpg" = "image/jpeg";
        "mimetype.jpeg" = "image/jpeg";
        "mimetype.pdf" = "application/pdf";
        "mimetype.png" = "image/png";
        "mimetype.svg" = "image/svg+xml";
      };
      nginx.virtualHost = cfg.domain;
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = cfg.domain;

      locations."~ /.+/(info/refs|git-upload-pack)" = {
        fastcgiParams = {
          # specifying config in /srv/git/.gitconfig is also valid
          GIT_CONFIG_COUNT = "1";
          GIT_CONFIG_KEY_0 = "safe.directory";
          GIT_CONFIG_VALUE_0 = "/srv/git/*";
        };
      };
    };

    security.acme.certs."${cfg.domain}".group = config.services.nginx.group;
  };
}
