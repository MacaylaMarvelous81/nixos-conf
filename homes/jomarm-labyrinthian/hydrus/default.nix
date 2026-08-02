{
  options,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.hydrus;
in
{
  options.homes.jomarm-labyrinthian.hydrus = {
    enable = lib.options.mkEnableOption "Configuration for hydrus network";
    package = lib.options.mkPackageOption pkgs "hydrus" { };
    finalPackage = lib.options.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Final wrapped Hydrus package.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        homes.jomarm-labyrinthian.hydrus.finalPackage = pkgs.symlinkJoin {
          inherit (cfg.package) pname version;
          paths = [ cfg.package ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/hydrus-client \
              --unset WAYLAND_DISPLAY \
              --add-flag '-d=${config.home.homeDirectory}/Hydrus'
          '';
        };

        home.packages = [ cfg.finalPackage ];
      }
      (lib.optionalAttrs (builtins.hasAttr "stylix" options) {
        home.file = lib.mkIf config.stylix.enable {
          # to apply this stylesheet, set the Qt stylesheet option under
          # style in the client options
          "Hydrus/static/qss/user.qss".source = config.lib.stylix.colors {
            template = ./user.qss.mustache;
            extension = ".qss";
          };
        };
      })
    ]
  );
}
