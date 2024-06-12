{ pkgs, lib, config, ... }:
let
  cfg = config.profile.sway;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alacritty
      tofi
      findutils
      networkmanagerapplet
    ];

    wayland.windowManager.sway = {
      enable = true;
    };

    wayland.windowManager.sway.extraConfigEarly = ''
      exec "nm-applet --indicator"
    '';
    wayland.windowManager.sway.config =
      let
        mod = "Mod4";
      in
      {
        modifier = mod;
        keybindings = lib.mkOptionDefault
          {
            "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec ${pkgs.tofi}/bin/tofi-drun | ${pkgs.findutils}/bin/xargs swaymsg exec --";
            "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec light -A 5";
            "XF86MonBrightnessDown" = "exec light -U 5";
          };

        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          style = "Bold Semi-Condensed";
          size = 11.0;
        };
        bars = [ ];
      };
    wayland.windowManager.sway.extraConfig = ''
      default_border none

      # class                 border    backgr.  text     indicator  child_border
      client.focused          #373b41   #373b41  #373b41  #373b41    #373b41
      client.focused_inactive #282a2e   #282a2e  #282a2e  #282a2e    #282a2e
      client.urgent           #f0c674   #f0c674  #f0c674  #f0c674    #f0c674
      client.placeholder      #373b41   #373b41  #373b41  #373b41    #373b41

      # swayfx config
      blur enable
      blur_xray enable
      blur_passes 3
      blur_radius 5
      layer_effects "waybar" shadows enable; blur enable;
      corner_radius 4
      # default_dim_inactive 0.2
      shadows enable
    '';
  };
}
