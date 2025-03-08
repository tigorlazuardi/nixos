{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  flavor = "mocha";
  catppuccin-theme = pkgs.stdenv.mkDerivation rec {
    pname = "catppuccin-theme-swaync";
    version = "0.2.3";
    src = pkgs.fetchurl {
      url = "https://github.com/catppuccin/swaync/releases/download/v${version}/${flavor}.css";
      hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
    };
    phases = [ "installPhase" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp $src $out/${flavor}.css
      sed -i 's#Ubuntu Nerd Font#JetBrainsMono Nerd Font#' $out/${flavor}.css
      runHook postInstall
    '';
  };
  rose-pine-repo = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "swaync";
    rev = "fc17ee01916a5e4424af5c5b29272383fcdfc4f3";
    hash = "sha256-BLJCr7cB1nwUVe48gQX6ZBHdlJn2fZ7dBQgnADYG2I0=";
  };
in
{
  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;
      # pkill swaync && GTK_DEBUG=interactive swaync - launch swaync with gtk debugger
      # style = builtins.readFile "${catppuccin-theme}/${flavor}.css";
      style = # css
        ''
          @import url("${rose-pine-repo}/theme/rose-pine.css");
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
            app-name = "^(?!discord|TelegramDesktop|Slack|slack|Signal|Element|whatsapp-for-linux|vesktop|spotify).*$";
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

    profile.hyprland.xdgPortal.screencast = {
      exec_before = # sh
        ''swaync-client --inhibitor-add "xdg-desktop-portal-hyprland"'';
      exec_after = # sh
        ''swaync-client --inhibitor-remove "xdg-desktop-portal-hyprland"'';
    };

    home.packages = with pkgs; [ libnotify ];

    # home.file.".config/wallust/templates/swaync_base16.css".text =
    # #css
    # ''
    # @define-color foreground {{foreground}};
    # @define-color background {{background}};
    # @define-color cursor {{cursor}};
    # @define-color color0 {{color0}};
    # @define-color color1 {{color1}};
    # @define-color color2 {{color2}};
    # @define-color color3 {{color3}};
    # @define-color color4 {{color4}};
    # @define-color color5 {{color5}};
    # @define-color color6 {{color6}};
    # @define-color color7 {{color7}};
    # @define-color color8 {{color8}};
    # @define-color color9 {{color9}};
    # @define-color color10 {{color10}};
    # @define-color color11 {{color11}};
    # @define-color color12 {{color12}};
    # @define-color color13 {{color13}};
    # @define-color color14 {{color14}};
    # @define-color color15 {{color15}};
    # '';
    # profile.hyprland.wallust.settings.templates =
    #   let
    #     out = config.home.homeDirectory + "/.cache/wallust";
    #   in
    #   {
    #     swaync = {
    #       template = "swaync_base16.css";
    #       target = "${out}/swaync_base16.css";
    #     };
    #   };
  };
}
