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
      # pkill swaync && GTK_DEBUG=interactive swaync - launch swaync with gtk debugger
      style =
        let
          # Origin: "https://github.com/zDyanTB/HyprNova/blob/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/notifications.css";
          notificationCss = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/zDyanTB/HyprNova/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/notifications.css";
            hash = "sha256-QIM60RX/OedhfkMKngj540d/9wj4E54ncv24nueYlyk=";
          };
          # Origin: https://github.com/zDyanTB/HyprNova/blob/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/central_control.css
          controlCenterCss = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/zDyanTB/HyprNova/5c2b4634a6971aaf995b4fc69cd74f8bbf0b84d0/.config/swaync/themes/nova-dark/central_control.css";
            hash = "sha256-XzFea04G4DCxDUF/XOqUkKei+Xv9bmdnSVU4/Sjtefc=";
          };
        in
        # css
        ''
          @import '${config.home.homeDirectory}/.cache/wallust/swaync_base16.css';
          @import '${controlCenterCss}';
          @import '${notificationCss}';

          .control-center {
            background: alpha(@background, 0.9);
          }

          .floating-notifications.background .notification-row .notification-background {
            background: alpha(@background, 0.9);
          }
        '';
      settings = {
        positionX = "center";
        positionY = "top";
        fit-to-screen = false;
        control-center-height = 800;
        timeout = 7;
        timeout-low = 5;
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = " 󰎟 ";
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
            app-name = "^(?!discord|TelegramDesktop|Slack|slack|Signal|Element|whatsapp-for-linux|vesktop).*$";
          };
        };
      };
    };

    systemd.user.services.swaync.Service.Environment = [ "G_MESSAGES_DEBUG=all" ];

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
