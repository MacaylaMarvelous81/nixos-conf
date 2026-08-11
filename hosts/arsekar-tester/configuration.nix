{ pkgs, ... }:
{
  imports = [
    ../../worlds
  ];

  config = {
    worlds.arsekar.enable = true;

    users.users.arsekar-test-user = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "password";
      packages = with pkgs; [ git ];
    };

    # avoid invalid requests to lets encrypt; should fall back to preliminary
    # self-signed certs
    security.acme.defaults.server = "https://localhost";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    system.stateVersion = "25.11";

    virtualisation.vmVariant = {
      virtualisation.memorySize = 8044;
      virtualisation.cores = 4;
    };
  };
}
