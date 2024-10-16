{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # services.swayosd = {
    #   enable = true;
    #   display = config.profile.hyprland.swayosd.display;
    # };
    home.packages = with pkgs; [
      swayosd
    ];

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "swayosd-libinput-backend"
        "swayosd-server"
      ];
      bindl = [
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ];
      # e -> repeat, will repeat when held.
      # l -> even when locked
      bindel = [
        # Media
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise --max-volume 150"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower --max-volume 150"

        # Light
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness +10"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -10"
      ];
    };
  };
}
