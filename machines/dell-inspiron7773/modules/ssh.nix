{
  config,
  lib,
  ...
}:
let
  cfg = config.machine.ssh;
in
{
  options.machine.ssh = {
    enable = lib.mkEnableOption "openssh options";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowGroups = [ "users" ];
      };
    };
  };
}
