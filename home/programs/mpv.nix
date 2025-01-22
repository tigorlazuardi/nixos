{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.mpv;
in
{
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        mpris
        thumbnail
        sponsorblock
      ];
    };
  };
}
