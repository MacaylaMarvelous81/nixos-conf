{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homes.jomarm-labyrinthian.web-browser;
in
{
  options.homes.jomarm-labyrinthian.web-browser = {
    enable = lib.mkEnableOption "home-manager Web browser configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      # new default value for state version 26.05
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles = {
        default = {
          search = {
            force = true;
            default = "startpage";
            engines = {
              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              nixos-wiki = {
                name = "NixOS Wiki";
                urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
                iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                definedAliases = [ "@nw" ];
              };
              mojeek = {
                name = "Mojeek";
                urls = [ { template = "https://www.mojeek.com/search?q={searchTerms}"; } ];
                iconMapObj."16" = "https://www.mojeek.com/favicon.png";
                definedAliases = [ "@mojeek" ];
              };
              searxng = {
                name = "SearXNG";
                description = "SearXNG is a metasearch engine that respects your privacy.";
                urls = [
                  { template = "https://searx.tiekoetter.com/search?q={searchTerms}"; }
                  {
                    template = "https://searx.tiekoetter.com/autocompleter?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                iconMapObj."16" = "https://searx.tiekoetter.com/static/themes/simple/img/favicon.png";
                definedAliases = [ "@searxng" ];
              };
              startpage = {
                name = "Startpage";
                description = "Startpage Search";
                urls = [
                  {
                    template = "https://www.startpage.com/sp/search?query={searchTerms}&amp;cat=web&amp;pl=opensearch&amp;language=english";
                  }
                  {
                    template = "https://www.startpage.com/osuggestions?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                iconMapObj."64" = "https://www.startpage.com/favicon.ico";
                iconMapObj."16" = "https://cdn.startpage.com/sp/cdn/favicons/favicon-16x16-gradient.png";
                definedAliases = [ "@startpage" ];
              };
            };
          };
          settings = lib.mkMerge [
            (lib.mkIf config.xdg.portal.enable {
              # 0 = never, 1 = always, 2 = automatic
              "widget.use-xdg-desktop-portal.file-picker" = 1;
            })
            {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            }
          ];
          userContent = ''
            @import "${./clocktower.css}"
          '';
        };
      };
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        GenerativeAI = {
          Enabled = false;
          Chatbot = false;
          LinkPreviews = false;
          TabGroups = false;
          Locked = true;
        };
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          Stories = false;
          SponsoredPocket = false;
          SponsoredStories = false;
          Snippets = false;
          Locked = true;
        };
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "newtab";
        DisplayMenuBar = "default-off";

        ExtensionSettings = {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "WebToEpub@Baka-tsuki.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/webtoepub-for-baka-tsuki/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    programs.librewolf = {
      enable = true;
      profiles = {
        default = {
          search = {
            force = true;
            default = "brave";
            engines = {
              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              nixos-wiki = {
                name = "NixOS Wiki";
                urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
                iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                definedAliases = [ "@nw" ];
              };
              mojeek = {
                name = "Mojeek";
                urls = [ { template = "https://www.mojeek.com/search?q={searchTerms}"; } ];
                iconMapObj."16" = "https://www.mojeek.com/favicon.png";
                definedAliases = [ "@mojeek" ];
              };
              searxng = {
                name = "SearXNG";
                description = "SearXNG is a metasearch engine that respects your privacy.";
                urls = [
                  { template = "https://searx.tiekoetter.com/search?q={searchTerms}"; }
                  {
                    template = "https://searx.tiekoetter.com/autocompleter?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                iconMapObj."16" = "https://searx.tiekoetter.com/static/themes/simple/img/favicon.png";
                definedAliases = [ "@searxng" ];
              };
              startpage = {
                name = "Startpage";
                description = "Startpage Search";
                urls = [
                  {
                    template = "https://www.startpage.com/sp/search?query={searchTerms}&amp;cat=web&amp;pl=opensearch&amp;language=english";
                  }
                  {
                    template = "https://www.startpage.com/osuggestions?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                iconMapObj."64" = "https://www.startpage.com/favicon.ico";
                iconMapObj."16" = "https://cdn.startpage.com/sp/cdn/favicons/favicon-16x16-gradient.png";
                definedAliases = [ "@startpage" ];
              };
              brave = {
                name = "Brave";
                description = "Brave Search: private, independent, open";
                urls = [
                  {
                    template = "https://search.brave.com/search?q={searchTerms}";
                  }
                  {
                    template = "https://search.brave.com/api/suggest?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                iconMapObj."32" =
                  "https://cdn.search.brave.com/serp/v1/static/brand/eebf5f2ce06b0b0ee6bbd72d7e18621d4618b9663471d42463c692d019068072-brave-lion-favicon.png";
                definedAliases = [ "@brave" ];
              };
            };
          };
          settings = {
            # or maybe a local file?
            "browser.startup.homepage" = "https://pyrodax.com";

            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
          userContent = ''
            @import "${./clocktower.css}"
          '';
        };
      };
      policies = {
        ExtensionSettings = {
          "*".installation_mode = "blocked";

          "WebToEpub@Baka-tsuki.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/webtoepub-for-baka-tsuki/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
  };
}
