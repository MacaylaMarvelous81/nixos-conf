{
  nixosEval ? import "${<nixpkgs>}/nixos/lib/eval-config.nix",
}:
nixosEval {
  modules = [
    ./configuration.nix
    (_: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      nixpkgs.hostPlatform = "x86_64-linux";
    })
  ];
}
