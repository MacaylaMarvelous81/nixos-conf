# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  sources = import ./npins;
in {
  imports = [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      (import "${ sources.home-manager }/nixos")

      ../../pinning.nix
    ];

  pinning.nixpkgs = sources.nixos;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dell-inspiron7773"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  swapDevices = [ {
    device = "/dev/sda2";
  } ];

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.prime = {
    sync.enable = true;

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jomarm = {
    isNormalUser = true;
    description = "Jomar Milan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  home-manager.users.jomarm = { ... }: {
    imports = [
      ../../home-manager/modules

      (import ../../home-manager/inputs.nix { inherit sources; })
    ];

    home.stateVersion = "24.11";

    home.packages = with pkgs; [
      limo
    ];

    usermod.email.enable = true;
    usermod.gpg.enable = true;
    usermod.neovim.enable = true;
    usermod.git.enable = true;
    usermod.shell.enable = true;
    usermod.ssh.enable = true;
    usermod.aerc.enable = true;
    usermod.offlineimap.enable = true;
    usermod.niri.enable = true;
    usermod.noctalia-shell.enable = true;
    usermod.stylix.enable = true;
    usermod.firefox.enable = true;
    usermod.secrets.enable = true;
    usermod.term.enable = true;

    programs.noctalia-shell.package = pkgs.callPackage "${ sources.noctalia-shell }/nix/package.nix" {};
    programs.niri.settings = {
      debug = {
        render-drm-device = "/dev/dri/card1";
      };
    };

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.dekstop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
      };
    };
  };

  nix.nixPath = [ "nixos-config=/etc/nixos/machines/dell-inspiron7773/configuration.nix" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.niri.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # List services that you want to enable:

  services.offlineimap.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
