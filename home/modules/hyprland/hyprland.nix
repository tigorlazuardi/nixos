{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    profile.home.programs.foot.enable = lib.mkForce true;
    profile.home.programs.nemo.enable = lib.mkForce true;

    home.packages = with pkgs; [
      wl-clipboard
      kcalc
      font-manager
      vivaldi
      unstable.hyprland-qt-support
      hyprpolkitagent
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # managed with uwsm
      # systemd.variables = [ "--all" ];
      settings = {
        # env = [ "DBUS_SESSION_BUS_ADDRESS,unix:path=/run/user/${toString config.profile.user.uid}/bus" ];
        # window decors
        general = {
          gaps_in = 10;
          gaps_out = 14;
          border_size = 3;
          layout = "dwindle";
        };

        master = {
          mfact = 0.75;
          new_status = "inherit";
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # master = {
        #   new_is_master = true;
        # };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_create_new = false;
        };

        workspace = cfg.settings.workspaces;

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            new_optimizations = "on";
            ignore_opacity = true;
            xray = true;
            # blurls = waybar
          };
          active_opacity = 1.0;
          inactive_opacity = 0.9;
          fullscreen_opacity = 1.0;
        };

        monitor = cfg.settings.monitors;
        "$mod" = "SUPER";

        # https://wiki.hyprland.org/Configuring/Binds
        bind = [
          # Programs
          ''$mod, RETURN, exec, kitty''
          "$mod, E, exec, nemo"
          "$mod, B, exec, vivaldi"
          "$mod, BackSpace, exec, wlogout"
          "$mod, Y, exec, foot ssh homeserver@vpn.tigor.web.id"

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
          "$mod CTRL, down, workspace, empty"

          # Window Management
          "$mod, Q, killactive"
          "$mod, Space, fullscreen"
          "$mod, G, togglefloating"
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, l, movewindow, r"
        ];

        binde = [
          "$mod CTRL, H, resizeactive, -100 0"
          "$mod CTRL, J, resizeactive, 0 100"
          "$mod CTRL, K, resizeactive, 0 -100"
          "$mod CTRL, L, resizeactive, 100 0"
        ];

        # m -> mouse
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        bindl = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPause, exec, playerctl pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86Calculator, exec, qalculate-gtk"
        ];

        input = {
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
          };
          mouse_refocus = false;
          sensitivity = 0;
          kb_options = config.profile.xkb.options;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = true;
          enable_swallow = true;
          swallow_regex = "^(foot|footclient|kitty|ghostty)$";
        };

        animations = {
          enabled = true;
          bezier = [
            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"
          ];
          animation = [
            "windows, 1, 6, wind, slide"
            "windowsIn, 1, 6, winIn, slide"
            "windowsOut, 1, 5, winOut, slide"
            "windowsMove, 1, 5, wind, slide"
            "border, 1, 1, liner"
            "borderangle, 1, 30, liner, loop"
            "fade, 1, 10, default"
            "workspaces, 1, 5, wind"
          ];
        };

        windowrulev2 = [
          config.profile.discord.window_rule
          config.profile.slack.window_rule
          config.profile.whatsapp.window_rule
          ''opaque,title:(.*)(- YouTube)(.*)$'' # Youtube
          ''opaque,title:^Meet - (.*)$'' # Google Meet
          ''opaque,class:^(mpv)$''
          ''float,class:^(lazygit)$''
          ''center,class:^(lazygit)$''
          ''size 90% 90%,class:^(lazygit)$''
          ''stayfocused,class:^(lazygit)$''
        ];

        exec-once = [
          "nm-applet"
          # "pasystray"
        ];
      };
      extraConfig = # hyprlang
        ''
          source=${config.home.homeDirectory}/.cache/wallust/hyprland.conf
        '';
    };

    home.file.".config/xdg-desktop-portal/hyprland-portals.conf".source =
      (pkgs.formats.ini { }).generate "hyprland-portals.conf"
        config.profile.hyprland.xdgPortal;
  };
}
