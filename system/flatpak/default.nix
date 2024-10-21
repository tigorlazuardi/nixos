{ config, lib, ... }:
let
  cfg = config.profile.flatpak;
  inherit (lib.lists) optional;
in
{
  config = lib.mkIf cfg.enable {
    fonts.fontDir.enable = true;
    services.flatpak = {
      enable = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };
      packages =
        [ ]
        ++ optional cfg.zen-browser.enable "io.github.zen_browser.zen"
        ++ optional cfg.redisinsight.enable "com.redis.RedisInsight";
    };
  };
}
