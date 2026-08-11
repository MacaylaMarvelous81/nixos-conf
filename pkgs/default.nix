args@{
  pkgs ? import <nixpkgs> args,
  lib ? pkgs.lib,
}:
lib.filesystem.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./exprs;
}
