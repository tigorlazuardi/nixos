{ config, lib, pkgs, ... }:
let
  cfg = config.profile.gnome;
in
{
  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
        # "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
        "org/gnome/desktop/wm/preferences" = {
          resize-with-right-button = true;
          button-layout = "appmenu:minimize,maximize,close";
          num-workspaces = 10;
        };
        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];
          switch-to-workspace-10 = [ "<Super>0" ];

          move-to-workspace-1 = [ "<Super><Shift>1" ];
          move-to-workspace-2 = [ "<Super><Shift>2" ];
          move-to-workspace-3 = [ "<Super><Shift>3" ];
          move-to-workspace-4 = [ "<Super><Shift>4" ];
          move-to-workspace-5 = [ "<Super><Shift>5" ];
          move-to-workspace-6 = [ "<Super><Shift>6" ];
          move-to-workspace-7 = [ "<Super><Shift>7" ];
          move-to-workspace-8 = [ "<Super><Shift>8" ];
          move-to-workspace-9 = [ "<Super><Shift>9" ];
          move-to-workspace-10 = [ "<Super><Shift>0" ];

          toggle-maximized = [ "<Super>space" ];
        };

        "org/gnome/shell/keybindings" = {
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];
        };

        "org/gnome/shell" = {
          disable-user-extensions = false;

          enabled-extensions = [
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "trayIconsReloaded@selfmade.pl"
            "gsconnect@andyholmes.github.io"
            "dashbar@fthx"
            "pano@elhan.io"
            "appindicatorsupport@rgcjonas.gmail.com"
            "drive-menu@gnome-shell-extensions.gcampax.github.com" # built-in to gnome DE
            "runcat@kolesnikov.se"
            "docker@stickman_0x00.com"
            "Vitals@CoreCoding.com"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super>F12" ];

        "org/gnome/deskto/input-sources".xkb-options = [
          "terminate:ctrl_alt_bksp"
          "caps:ctrl_modifier"
          "shift:both_capslock_cancel"
        ];
      };
    };

    home.packages = with pkgs; [
      gnomeExtensions.user-themes
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.pano
      gnomeExtensions.dashbar
      gnomeExtensions.gsconnect
      gnomeExtensions.appindicator
      gnomeExtensions.runcat
      gnomeExtensions.docker
      gnomeExtensions.vitals
      gnomeExtensions.espresso
      gnomeExtensions.forge

      gnome.dconf-editor
      gnome.gnome-tweaks
      libappindicator-gtk2
    ];
  };

}
