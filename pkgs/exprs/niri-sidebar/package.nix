{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-sidebar";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Vigintillionn";
    repo = "niri-sidebar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MYP1ZiwV9+yJhl0zpuri6NQkQHlaYZjGBhXpZEaPZyI=";
  };

  cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";

  meta = {
    description = "External sidebar manager for the Niri window manager";
    homepage = "https://github.com/Vigintillionn/niri-sidebar/";
    downloadPage = "https://github.com/Vigintillionn/niri-sidebar/releases/";
    license = lib.licenses.mit;
  };
})
