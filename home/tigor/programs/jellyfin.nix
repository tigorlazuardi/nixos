{ config, lib, unstable, ... }:
let
  cfg = config.profile.jellyfin;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf cfg.client.enable [
      unstable.jellyfin-media-player
    ];
  };
}
