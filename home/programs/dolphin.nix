{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.dolphin;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.kdegraphics-thumbnailers
      libappimage
      icoutils
      taglib
      ffmpegthumbs
      resvg
      kdePackages.ark
      kdePackages.kio-admin
      kdePackages.kio-gdrive
      kdePackages.kio-extras
      kdePackages.konsole
    ];
  };
}
