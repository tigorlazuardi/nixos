{ config, lib, pkgs, ... }:
let
  cfg = config.profile.firefox;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
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
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"
      };
      profiles = {
        tigor = {
          id = 0;
          name = "Tigor";
          isDefault = true;
          extensions = with pkgs.nur.repos.rycee.firefox-addons;  [
            ublock-origin
            bitwarden
            cookie-autodelete
            old-reddit-redirect
            reddit-enhancement-suite
            vimium-c
            violentmonkey
            sidebery
          ];
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
        };
      };
    };
  };
}
