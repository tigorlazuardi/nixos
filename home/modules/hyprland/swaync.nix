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
    services.poweralertd.enable = true;
    services.swaync = {
      enable = true;
      style =
        let
          # Origin: "https://github.com/zDyanTB/HyprNova/blob/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/notifications.css";
          notificationCss = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/zDyanTB/HyprNova/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/notifications.css";
            hash = "sha256-QIM60RX/OedhfkMKngj540d/9wj4E54ncv24nueYlyk=";
          };
          controlCenterCss = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/zDyanTB/HyprNova/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/central_control.css";
            hash = "sha256-XzFea04G4DCxDUF/XOqUkKei+Xv9bmdnSVU4/Sjtefc=";
          };
        in
        # Origin: https://github.com/zDyanTB/HyprNova/blob/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/central_control.css
        # css
        ''
          @import '${config.home.homeDirectory}/.cache/wallust/swaync_base16.css';
          @import '${controlCenterCss}';
          @import '${notificationCss}';
        '';
      settings = {
        positionX = "center";
        positionY = "top";
        fit-to-screen = true;
        control-center-height = 800;
        timeout = 7;
        timeout-low = 5;
        widgets = [
          # "label"
          # "buttons-grid"
          "mpris"
          # "volume"
          "title"
          "dnd"
          "notifications"
        ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = " 󰎟 ";
          };
          label = {
            max-lines = 1;
            text = " ";
          };
          mpris = {
            image-size = 96;
            image-radius = 12;
          };
        };

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

    wayland.windowManager.hyprland.settings.layerrule = [
      "blur, swaync-notification-window"
      "blur, swaync-control-center"
      "ignorezero, swaync-notification-window"
      "ignorezero, swaync-control-center"
      "ignorealpha 0.5, swaync-notification-window"
      "ignorealpha 0.5, swaync-control-center"
    ];

    home.packages = with pkgs; [ libnotify ];
  };
}
