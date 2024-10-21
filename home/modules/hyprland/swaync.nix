{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;
      style = pkgs.fetchurl {
        url = "https://github.com/catppuccin/swaync/releases/download/v0.2.3/mocha.css";
        hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
      };
      settings = {
        positionX = "center";
        positionY = "top";
        fit-to-screen = false;
        control-center-height = 800;
        timeout = 5;
        timeout-low = 3;

        scripts = {
          _10-hyprland-ytptube = {
            app-name = "ytptube";
            exec = ''hyprctl dispatch exec "xdg-open https://ytptube.tigor.web.id"'';
            run-on = "action";
          };
          _98-play-notification-sound-normal = {
            exec = ''${pkgs.sox}/bin/play --volume 0.5 ${./gran_turismo_menu_sound_effect.mp3}'';
            app-name = "^(?!discord|TelegramDesktop|Slack|slack|Signal|Element|whatsapp-for-linux).*$";
          };
        };
      };
    };

    home.packages = with pkgs; [ libnotify ];
  };
}
