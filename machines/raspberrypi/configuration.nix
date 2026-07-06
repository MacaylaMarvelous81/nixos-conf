{
  config,
  pkgs,
  nixos-raspberrypi,
  ...
}:
let
  pkgsHost = import pkgs.path {
    localSystem = "x86_64-linux";
  };

  pkgsCross = import pkgs.path {
    overlays = [
      (final: prev: {
        matrix-continuwuity = prev.matrix-continuwuity.overrideAttrs (
          finalAttrs: prevAttrs: {
            version = "0.5.10";

            src = final.fetchFromGitea {
              domain = "forgejo.ellis.link";
              owner = "continuwuation";
              repo = "continuwuity";
              tag = "v${finalAttrs.version}";
              hash = "sha256-oevEGYlAK/rMJhm200CkwerT5oVak8sJj0Fa6r6+J/Q=";
            };

            cargoDeps = prev.rustPlatform.fetchCargoVendor {
              inherit (finalAttrs) version src;
              name = "${finalAttrs.pname}-${finalAttrs.version}-vendor";
              hash = "sha256-uvMiFURXxkLbbbwq4pG5hevsLZHQ1wVfTNvzQRTQWxE=";
            };
          }
        );
      })
    ];

    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in
{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
  ];

  boot.loader.raspberry-pi.bootloader = "kernel";

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

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "x-initrd.mount"
        "noatime"
      ];
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
  };

  nix.settings.trusted-users = [ "@wheel" ];

  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.overlays = [
    (final: prev: {
      matrix-continuwuity = pkgsCross.matrix-continuwuity.override {
        inherit (final)
          bzip2
          zstd
          rust-jemalloc-sys-unprefixed
          liburing
          rocksdb
          ;
        inherit (pkgsHost) pkg-config;
      };
    })
  ];

  system.stateVersion = "25.11";
}
