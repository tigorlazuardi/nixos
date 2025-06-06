{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.profile.spotify;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ spotify ];
    # home.packages = with pkgs; [
    #   (spotifywm.overrideAttrs {
    #     version = "azurmeau-fork";
    #     src = fetchFromGitHub {
    #       owner = "amurzeau";
    #       repo = "spotifywm";
    #       rev = "b2222c9da47b278a3addef48250513420df405ac";
    #       hash = "sha256-kRBOV2jPJ81xGEgCbSBcOo4Ie9FoK1kfxXMQG1vhHfM=";
    #     };
    #   })
    # ];

    # services.swaync.settings.scripts._10-spotify = {
    #   app-name = "spotifywm";
    #   exec = "hyprctl dispatch focuswindow spotify";
    #   run-on = "action";
    # };

    # services.spotifyd = lib.mkIf cfg.spotifyd.enable {
    #   enable = true;
    #   settings = {
    #     global = {
    #       use_keyring = false;
    #       use_mpris = true;
    #       device_type = "speaker";
    #       device_name = "Spotifyd";
    #     };
    #   };
    # };
  };
}
