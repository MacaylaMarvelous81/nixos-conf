{
  rustPlatform,
  stdenvNoCC,
  lib,
  fetchFromGitHub,

  alsa-lib,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  pname = "jomarm-offlineimap-postsynchook";
  version = "0-unstable-2025-12-21";

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    alsa-lib
  ];
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    pkg-config
  ];

  src = fetchFromGitHub {
    owner = "MacaylaMarvelous81";
    repo = "offlineimap-postsynchook";
    rev = "8b13829b034c54207a36dff32b73b08656a685cc";
    hash = "sha256-VYmGu2ZSmjeR88J+2CZ1L6fu+KLIyuN/omYzUg+Yyyo=";
  };

  cargoHash = "sha256-xyGHUUeaF7V6IEB7UHZf0eqzZrHUcuEeFiEyMB0vTJ4=";
}
