{
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "raspberrypi";

  users.users.jomarm = {
    isNormalUser = true;
    description = "Jomar Milan";
    extraGroups = [ "wheel" ];
    initialPassword = "raspberrypi";
    packages = with pkgs; [ git ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOfZ3GVOc4/hDqYzxlfg41y5MgtVD9WQxmN90QtHt4I jomarm@Jomars-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpBFduvcSClZ7EtSMfhilspvAbOh6zs5zGUSZba2pKT jomarm@jomar-inspiron7773"
    ];
  };

  users.groups."${config.services.matrix-continuwuity.group}".members = [
    config.services.nginx.user
  ];
  # dynamicuser group pairs
  # systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "miniflux" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowGroups = [ "users" ];
    };
  };

  services.cgit."git.pyrodax.com" = {
    enable = true;
    scanPath = "/srv/git";
    gitHttpBackend = {
      enable = true;
      checkExportOkFiles = false;
    };
    nginx.virtualHost = "git.pyrodax.com";
  };

  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "pyrodax.com";
        unix_socket_path = "/run/continuwuity/continuwuity.sock";
        # allow_registration = false;
        well_known = {
          client = "https://matrix.pyrodax.com";
          server = "matrix.pyrodax.com:443";
        };
      };
    };
  };

  # services.miniflux = {
  #   enable = true;
  #   config = {
  #     BASE_URL = "http://miniflux.raspberrypi.lan";
  #     # The NixOS module enables this by default even though the miniflux
  #     # default is disabled.
  #     CREATE_ADMIN = false;
  #     LISTEN_ADDR = "/run/miniflux/miniflux.sock";
  #   };
  # };

  services.nginx = {
    enable = true;
    virtualHosts."pyrodax.com" = {
      forceSSL = true;
      useACMEHost = "pyrodax.com";
      root = "/srv/www";
      locations."/.well-known/matrix/" = {
        proxyPass = "http://unix:/run/continuwuity/continuwuity.sock:/.well-known/matrix/";
        recommendedProxySettings = true;
      };
    };
    virtualHosts."openpgpkey.pyrodax.com" = {
      forceSSL = true;
      useACMEHost = "pyrodax.com";
      # if separate root used, static website could be built with nix?
      locations."/.well-known/openpgpkey/" = {
        root = "/srv/www";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
    virtualHosts."git.pyrodax.com" = {
      forceSSL = true;
      useACMEHost = "git.pyrodax.com";
    };
    virtualHosts."matrix.pyrodax.com" = {
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
      useACMEHost = "matrix.pyrodax.com";
      locations."/" = {
        proxyPass = "http://unix:/run/continuwuity/continuwuity.sock:$request_uri";
        recommendedProxySettings = true;
      };
      extraConfig = ''
        client_max_body_size 20M;
      '';
    };
    # virtualHosts."miniflux.raspberrypi.lan" = {
    #   locations."/" = {
    #     proxyPass = "http://unix:/run/miniflux/miniflux.sock:$request_uri";
    #     recommendedProxySettings = true;
    #   };
    # };
  };

  services.prosody = {
    enable = true;
    admins = [ "jomarm@pyrodax.com" ];
    ssl.cert = "/var/lib/prosody/fullchain.pem";
    ssl.key = "/var/lib/prosody/key.pem";
    virtualHosts."pyrodax.com" = {
      enabled = true;
      domain = "pyrodax.com";
      ssl.cert = "/var/lib/prosody/fullchain.pem";
      ssl.key = "/var/lib/prosody/key.pem";
    };
    muc = [ { domain = "conference.pyrodax.com"; } ];
    httpFileShare = {
      domain = "upload.pyrodax.com";
    };
    extraConfig = ''
      -- only needed for prosodyctl check dns
      external_addresses = { "24.130.29.83", "2601:640:cc02:cd3e:6463:1172:452e:9e21" }
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jomarm@pyrodax.com";
    defaults.webroot = "/var/lib/acme/acme-challenge/";
    certs = {
      "pyrodax.com" = {
        group = config.services.nginx.group;
        extraDomainNames = [
          "conference.pyrodax.com"
          "upload.pyrodax.com"
          "openpgpkey.pyrodax.com"
        ];
        postRun = ''
          install -o prosody -g prosody fullchain.pem /var/lib/prosody/fullchain.pem
          install -o prosody -g prosody key.pem /var/lib/prosody/key.pem
        '';
      };
      "git.pyrodax.com" = {
        group = config.services.nginx.group;
      };
      "matrix.pyrodax.com" = {
        group = config.services.nginx.group;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    # Standard HTTP/HTTPS
    80
    443

    # XMPP
    5000
    5222
    5269
    5281
  ];

  system.activationScripts = {
    expire-passwords = {
      deps = [ "users" ];
      text = ''
        if ! ${pkgs.systemd}/bin/systemd-detect-virt --quiet; then
          if [ ! -e /var/lib/expire-passwords/jomarm ]; then
            if id -u >/dev/null 2>&1; then
              ${pkgs.shadow}/bin/chage -d 0 jomarm
              mkdir -p /var/lib/expire-passwords
              touch /var/lib/expire-passwords/jomarm
            fi
          fi
        fi
      '';
    };
  };

  nix.settings.trusted-users = [ "@wheel" ];

  system.stateVersion = "25.11";

  virtualisation.vmVariant = {
    # avoid invalid requests to lets encrypt; should fall back to preliminary
    # self-signed certs
    security.acme.defaults.server = "https://localhost";

    virtualisation.memorySize = 8044;
    virtualisation.cores = 4;

    # port forwarding with ssh should be sufficient to access other ports from host
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };
}
