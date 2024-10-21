{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.jellyfin;
in
{
  config = lib.mkIf cfg.enable { home.packages = [ pkgs.jellyfin-media-player ]; };
}
