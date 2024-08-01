{ config, lib, ... }:
let
  cfg = config.profile.home.programs.foot;
in
{
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font Mono:size=12";
          include = lib.mkIf config.profile.hyprland.enable "${config.home.homeDirectory}/.config/foot/colors.ini";
        };
        mouse = {
          hide-when-typing = "yes";
        };
        cursor = {
          style = "beam";
          blink = "yes";
        };
      };
    };
  };
}
