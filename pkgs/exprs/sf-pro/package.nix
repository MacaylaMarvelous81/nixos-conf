{
  stdenvNoCC,
  fetchurl,
  p7zip,
}:
stdenvNoCC.mkDerivation {
  pname = "sf-pro";
  version = "0-unstable-2026-07-24";

  src = fetchurl {
    # It may be better to use an Internet Archive URL so that this isn't invalidated.
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    hash = "sha256-YxGk8IQ6TS5hagsFx3US0x0uqVBFnPUmzbW5CZageU8=";
  };
  dontUnpack = true;

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall

    7z x "$src"
    cd SFProFonts
    7z x 'SF Pro Fonts.pkg'
    7z x 'Payload~'
    install -Dm644 Library/Fonts/* --target-directory="$out/share/fonts/sf-pro"

    runHook postInstall
  '';
}
