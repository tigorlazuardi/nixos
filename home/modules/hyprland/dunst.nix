{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib) mkIf;
  inherit (lib.meta) getExe;
  playNotificationSoundScript = pkgs.writeShellScriptBin "play-notification-sound" ''
    appname="$1"

    if [[ "$appname" =~ ^(discord|TelegramDesktop|Slack|Signal|Element|fcitx5|spotify)$ ]]; then
      exit 0
    fi

    ${pkgs.sox}/bin/play --volume 0.5 ${./gran_turismo_menu_sound_effect.mp3}
  '';
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gojq ];

    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      # https://dunst-project.org/documentation/
      settings = {
        global = {
          monitor = cfg.dunst.monitor;
          enable_posix_regex = true;
          origin = "top-center";
          # (horizontax, vertical)
          offset = "0x30";
          progress_bar_corner_radius = 10;
          # The transparency of the window.  Range: [0; 100].
          # This option will only work if a compositing window manager is
          # present (e.g. xcompmgr, compiz, etc.). (X11 only)
          transparency = 30;
          frame_color = "#ffffff";
          sort = true;
          idle_threshold = "1m";
          font = "Fira Sans Semibold 9";
          line_height = 1;

          # Possible values are:
          # full: Allow a small subset of html markup in notifications:
          #        <b>bold</b>
          #        <i>italic</i>
          #        <s>strikethrough</s>
          #        <u>underline</u>
          #
          #        For a complete reference see
          #        <https://docs.gtk.org/Pango/pango_markup.html>.
          #
          # strip: This setting is provided for compatibility with some broken
          #        clients that send markup even though it's not enabled on the
          #        server. Dunst will try to strip the markup but the parsing is
          #        simplistic so using this option outside of matching rules for
          #        specific applications *IS GREATLY DISCOURAGED*.
          #
          # no:    Disable markup parsing, incoming notifications will be treated as
          #        plain text. Dunst will not advertise that it has the body-markup
          #        capability if this is set as a global setting.
          #
          # It's important to note that markup inside the format option will be parsed
          # regardless of what this is set to.
          markup = "full";
          # The format of the message.  Possible variables are:
          #   %a  appname
          #   %s  summary
          #   %b  body
          #   %i  iconname (including its path)
          #   %I  iconname (without its path)
          #   %p  progress value if set ([  0%] to [100%]) or nothing
          #   %n  progress value if set without any extra characters
          #   %%  Literal %
          # Markup is allowed
          format = ''<b>%s</b>\n%b'';
          # Recursive icon lookup. You can set a single theme, instead of having to
          # define all lookup paths.
          enable_recursive_icon_lookup = true;
          # # Set icon theme (only used for recursive icon lookup)
          # icon_theme = ''"Papirus-Dark,Adwaita"'';
          ### Misc/Advanced ###

          # dmenu path.
          dmenu = "${pkgs.dmenu-wayland}/bin/dmenu-wl -p dunst";

          # Browser for opening urls in context menu.
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          # Define the corner radius of the notification window
          # in pixel size. If the radius is 0, you have no rounded
          # corners.
          # The radius will be automatically lowered if it exceeds half of the
          # notification height to avoid clipping text and/or icons.
          corner_radius = 10;

          mouse_left_click = "open_url, close_current";
          mouse_middle_click = "close_current";
          mouse_right_click = "do_action, close_current";
        };
        urgency_low = {
          background = "#000000CC";
          foreground = "#888888";
          script = "${getExe playNotificationSoundScript}";
          timeout = 6;
        };
        urgency_normal = {
          background = "#000000CC";
          foreground = "#888888";
          script = "${getExe playNotificationSoundScript}";
          timeout = 6;
        };
        urgency_critical = {
          background = "#000000CC";
          foreground = "#888888";
          script = "${getExe playNotificationSoundScript}";
        };
        fcitx5 = {
          appname = "fcitx5";
          skip_display = true;
        };
      };
    };
  };
}
