{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profile.obs;
in
{
  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-pipewire-audio-capture
        wlrobs
      ];
    };
  };
}
