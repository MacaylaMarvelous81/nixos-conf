{ lib, ... }:
{
  # waffle8946: https://discourse.nixos.org/t/a-cool-function-to-import-nix-modules-automatically/62757/3
  imports = builtins.filter (lib.strings.hasSuffix ".nix") (
    map toString (builtins.filter (p: p != ./default.nix) (lib.filesystem.listFilesRecursive ./.))
  );
}
