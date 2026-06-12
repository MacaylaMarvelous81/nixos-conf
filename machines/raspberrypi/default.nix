{
  sources ? import ./npins,
  nixos-raspberrypi ? import sources.nixos-raspberrypi,
}:
nixos-raspberrypi.lib.nixosSystem {
  modules = [ ./configuration.nix ];
}
