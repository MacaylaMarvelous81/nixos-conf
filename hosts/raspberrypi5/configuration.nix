{ pkgs, ... }:
{
  imports = [
    ../../worlds
  ];

  config = {
    worlds.arsekar.enable = true;

    users.users.jomarm = {
      isNormalUser = true;
      description = "Jomar Milan";
      extraGroups = [ "wheel" ];
      initialPassword = "raspberrypi5";
      packages = with pkgs; [ git ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOfZ3GVOc4/hDqYzxlfg41y5MgtVD9WQxmN90QtHt4I jomarm@Jomars-MacBook-Pro.local"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpBFduvcSClZ7EtSMfhilspvAbOh6zs5zGUSZba2pKT jomarm@jomar-inspiron7773"
      ];
    };

    boot.kernelParams = [ "console=ttyAMA10,115200n8" ];

    nixpkgs.hostPlatform = "aarch64-linux";

    nix.settings.trusted-users = [ "@wheel" ];

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
    system.stateVersion = "26.05";
  };
}
