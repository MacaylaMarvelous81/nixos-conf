{
  options,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.text-editor;
in
{
  options.homes.jomarm-labyrinthian.text-editor = {
    enable = lib.options.mkEnableOption "User text editor configuration";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = builtins.hasAttr "lazyvim" options.programs;
            message = "text editor module requires lazyvim-nix";
          }
        ];

        home.sessionVariables = {
          # lazyvim-nix uses programs.neovim
          EDITOR = "${config.programs.neovim.package}/bin/nvim";
        };

        programs.neovide.enable = true;
      }
      (lib.optionalAttrs (builtins.hasAttr "lazyvim" options.programs) {
        programs.lazyvim = {
          enable = true;
          extras = {
            lang.nix = {
              enable = true;
              config = ''
                return {
                  "neovim/nvim-lspconfig",
                  opts = {
                    servers = {
                      nixd = {},
                    },
                  },
                }
              '';
            };
            lang.rust.enable = true;
          };
          plugins = {
            live-share = ''
              return {
                "azratul/live-share.nvim",
                config = function()
                  require("live-share.provider").register("loopback", {
                    command = function(_, port, service_url) return string.format(
                        [[printf 'tcp://127.0.0.1:%d\n' > %s; sleep infinity]],
                        port, service_url)
                    end,
                    pattern = "tcp://[%w._-]+:%d+",
                  })
                  require("live-share.provider").register("raspberrypi", {
                    command = function(cfg, port_internal, service_url)
                      return string.format(
                        "ssh -R 0.0.0.0:%d:localhost:%d raspberrypi " .. "'echo tcp://24.130.29.83:%d; sleep infinity' > %s 2>/dev/null",
                        cfg.port, port_internal, cfg.port, service_url)
                    end,
                    pattern = "tcp://[%w.+=]+:%d+",
                  })
                  require("live-share").setup({
                    username = "jomarm",
                    service = "raspberrypi",
                    port = 8443,
                    openssl_lib = "${pkgs.openssl.out}/lib/libcrypto.so.3",
                  })
                end,
              }
            '';
          };
          extraPackages = with pkgs; [
            nixd
            nixfmt
            statix
          ];
        };
      })
    ]
  );
}
