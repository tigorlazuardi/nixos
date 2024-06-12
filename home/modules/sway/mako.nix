{ lib, config, ... }:
with lib;
let
  cfg = config.profile.sway;
in
{
  # Notification daemon for wayland
  config = mkIf (cfg.enable && cfg.mako.enable) {
    services.mako = {
      enable = true;
      padding = "5";
      backgroundColor = "#050505";
      borderSize = 1;
      borderColor = "#454545";
      font = "JetBrainsMono Nerd Font 10";
    };
  };
}
