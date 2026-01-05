{ config, lib, ... }:
let
  cfg = config.machine.backup;
in {
  options.machine.backup = {
    enable = lib.mkEnableOption "backups with borgbackup";
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs = {
      home-jomarm = {
        paths = "/home/jomarm";
        exclude = [
          "/home/jomarm/.cache"
        ];
        repo = "/mnt/backup-disk/dell-inspiron7773-borg";
        doInit = false;
        removableDevice = true;
        encryption.mode = "none";
        compression = "auto,lzma";
        startAt = "hourly";
        # startAt = [];
      };
    };

    fileSystems."/mnt/backup-disk" = {
      device = "/dev/disk/by-uuid/921639a8-ad5e-476b-a810-1d92ba851198";
      fsType = "ext4";
      options = [ "noauto" "nofail" "x-systemd.automount" "x-systemd.device-timeout=1ms" "x-systemd.idle-timeout=5m" ];
    };

    # services.udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEM=="block", ENV{ID_PART_TABLE_UUID}=="251029a8-91d2-4ee9-8554-59c4635d80fb", TAG+="systemd", ENV{SYSTEMD_WANTS}+="trigger-borgbackup@%p.service"
    # '';
    #
    # systemd.services."trigger-borgbackup@" = {
    #   description = "Trigger borgbackup job after mounting device at %i";
    # };
  };
}
