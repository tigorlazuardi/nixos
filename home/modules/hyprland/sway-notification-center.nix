{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
      libnotify
    ];

    # Config: https://manpages.debian.org/testing/sway-notification-center/swaync.5.en.html
    home.file.".config/swaync/config.json".text = builtins.toJSON {
      positionX = "center";
      positionY = "top";
      fit-to-screen = false;
      control-center-height = 800;
      timeout = 5;
      timeout-low = 3;

      scripts = {
        play-notification-sound = {
          exec = ''${pkgs.sox}/bin/play --volume 0.5 ${./gran_turismo_menu_sound_effect.mp3}'';
          app-name = "^(?!discord|TelegramDesktop|Slack|Signal|Element).*$";
          urgency = "Normal";
        };
      };
    };

    home.file.".config/swaync/style.css".source = pkgs.fetchurl {
      url = "https://github.com/catppuccin/swaync/releases/download/v0.2.3/mocha.css";
      hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
    };

    wayland.windowManager.hyprland.settings.exec-once = [
      "swaync"
    ];
  };
}
