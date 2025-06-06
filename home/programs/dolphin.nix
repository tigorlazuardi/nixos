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
    profile.hyprland.xdgPortal.preferred."org.freedesktop.impl.portal.FileChooser" = "kde";
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.kdegraphics-thumbnailers
      libappimage
      icoutils
      taglib
      kdePackages.ffmpegthumbs
      resvg
      kdePackages.ark
      kdePackages.kio-admin
      kdePackages.kio-gdrive
      kdePackages.kio-extras
      kdePackages.konsole
      kdePackages.kio-fuse
      kdePackages.qtsvg
      kdePackages.wayland
      kdePackages.wayland-protocols
      kdePackages.plasma-workspace
    ];
  };
}
