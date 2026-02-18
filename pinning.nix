{ config, lib, ... }:
let
  cfg = config.pinning;
in
{
  options.pinning = {
    nixpkgs = lib.mkOption {
      description = "The path to the nixpkgs version to pin at";
    };
    npinsDirectory = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The directory to the npins directory to use when updating";
    };
  };

  config = {
    # https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
    nix.channel.enable = false;
    nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];

    nixpkgs.overlays = lib.optional (cfg.npinsDirectory != "") (
      final: prev: {
        nixos-rebuild-ng = prev.nixos-rebuild-ng.overrideAttrs (prevAttrs: {
          nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
          postInstall = (prevAttrs.postInstall or "") + ''
            wrapProgram $out/bin/nixos-rebuild \
              --run 'export NIX_PATH="nixpkgs=$(${final.npins}/bin/npins --directory ${cfg.npinsDirectory} get-path nixos):$NIX_PATH"'
          '';
        });
      }
    );

    environment.etc = {
      "nixos/nixpkgs".source = cfg.nixpkgs;
    };
  };
}
