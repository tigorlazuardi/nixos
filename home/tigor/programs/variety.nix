{ config, lib, pkgs, ... }:
let
  cfg = config.profile.variety;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.variety ];

    home.file.".config/autostart.variety.desktop" = lib.mkIf cfg.autostart {
      source = "${pkgs.variety}/share/applications/variety.desktop";
    };
  };

}
