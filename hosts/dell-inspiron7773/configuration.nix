{
  config,
  pkgs,
  lib,
  ...
}:
let
  sources = import ./tamal { };
in
{
  imports = [
    ../../worlds

    (import "${sources.home-manager}/nixos")

    ./hardware-configuration.nix
  ];

  config = {
    worlds.labyrinthia.enable = true;

    users.users.jomarm = {
      isNormalUser = true;
      description = "Jomar Milan";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOfZ3GVOc4/hDqYzxlfg41y5MgtVD9WQxmN90QtHt4I jomarm@Jomars-MacBook-Pro.local"
      ];
    };

    home-manager.users.jomarm =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [
          ../../homes

          (import sources.stylix).homeModules.stylix
          "${sources.lazyvim-nix}/nix/module.nix"
        ];

        homes.jomarm-labyrinthian.enable = true;
        homes.jomarm-labyrinthian.games.vintagestory.package = pkgs.vintagestory.overrideAttrs (
          finalAttrs: prevAttrs: {
            # Applies to both vintagestory and vintagestory-server. I don't
            # necessarily want to set these for vintagestory-server, but I also want
            # to avoid wrapping a wrapper.
            makeWrapperArgs = [
              "--suffix"
              "__NV_PRIME_RENDER_OFFLOAD=1"
              "--suffix"
              "__NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0"
              "--suffix"
              "__GLX_VENDOR_LIBRARY_NAME=nvidia"
              "--suffix"
              "__VK_LAYER_NV_optimus=NVIDIA_only"
            ]
            ++ prevAttrs.makeWrapperArgs;
          }
        );

        accounts.email.accounts."jomarm".passwordCommand =
          "cat ${config.home.homeDirectory}/.secrets/jomarm@pyrodax.com";

        nixpkgs.overlays = [
          (final: prev: import ../../pkgs { pkgs = prev; })
        ];
        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "aseprite"
            "idea"
            "rider"
            "unrar"
            "vintagestory"
          ];

        home.stateVersion = "24.11";
      };

    environment.etc = {
      "nixos/nixpkgs".source = builtins.storePath pkgs.path;
    };

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    hardware.nvidia = {
      branch = "legacy_580";
      modesetting.enable = true;
      open = false;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;

        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
      powerManagement.enable = true;
    };

    nix.channel.enable = false;
    nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking.networkmanager.enable = true;

    time.timeZone = "America/Los_Angeles";

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    swapDevices = [
      {
        device = "/dev/sda2";
      }
    ];

    services.blueman.enable = true;
    services.printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
    };
    services.udisks2.enable = true;

    hardware.bluetooth.enable = true;
    hardware.printers = {
      ensurePrinters = [
        {
          name = "Brother_DCP-L2540DW";
          location = "Home";
          deviceUri = "ipp://BRN30055C8A983A";
          model = "drv:///brlaser.drv/brl2540d.ppd";
        }
      ];
      ensureDefaultPrinter = "Brother_DCP-L2540DW";
    };

    nixpkgs.overlays = [
      (final: prev: import ../../pkgs { pkgs = prev; })
    ];
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-settings"
        "nvidia-kernel-modules"
        "nvidia-x11"
        "steam"
        "steam-unwrapped"
      ];

    system.stateVersion = "25.11";

    # -vga none -device virtio-vga-gl -display sdl,gl=on
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 8192;
        cores = 4;
      };

      users.users.jomarm.initialPassword = "password";
    };
  };
}
