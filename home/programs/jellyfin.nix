{ config, lib, unstable, ... }:
let
  cfg = config.profile.jellyfin;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      unstable.jellyfin-media-player
    ];
  };
}
