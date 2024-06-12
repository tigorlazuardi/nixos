{ lib, pkgs, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swappy ];

    home.file.".config/swappy/config".text = ''
      [Default]
      save_dir=${config.home.homeDirectory}/Pictures/screenshots
      save_filename_format=swappy-%Y%m%d-%H%M%S.png
      show_panel=true
      line_size=5
      text_size=20
      text_font=sans-serif
      paint_mode=brush
      early_exit=true
      fill_shape=false
    '';
  };
}
