{
  nixos-raspberrypi ? import (fetchTarball {
    url = "https://github.com/nvmd/nixos-raspberrypi/archive/refs/tags/v1.20260801.0.tar.gz";
    sha256 = "sha256:08xq347rgbq95qphfgcwic7hdzabm8xpkd08ban2598cwnawwgr9";
  }),
}:
nixos-raspberrypi.lib.nixosSystem {
  modules = [ ./configuration.nix ];
}
