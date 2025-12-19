{ sources }: { ... }:
{
  imports = [ (import "${sources.home-manager}/nixos") ];

  # https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
  nix.channel.enable = false;
  nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];

  environment.etc = {
    "nixos/nixpkgs".source = sources.nixos;
  };
}
