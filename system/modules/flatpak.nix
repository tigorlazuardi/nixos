{ config, pkgs, lib, ... }:
let
  cfg = config.profile.flatpak;
in
{
  config = lib.mkIf cfg.enable {
    # Allow flatpak to access fonts
    fonts.fontDir.enable = true;

    services.flatpak.enable = true;
    # system.fsPackages = [ pkgs.bindfs ];

    # Allows user installed fonts to be accessed by flatpak
    # fileSystems =
    #   let
    #     mkRoSymBind = path: {
    #       device = path;
    #       fsType = "fuse.bindfs";
    #       options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    #     };
    #     aggregatedFonts = pkgs.buildEnv {
    #       name = "system-fonts";
    #       paths = config.fonts.packages;
    #       pathsToLink = [ "/share/fonts" ];
    #     };
    #   in
    #   {
    #     # Create an FHS mount to support flatpak host icons/fonts
    #     "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    #     "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
    #   };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # extraPortals = with pkgs; [
      #   # xdg-desktop-portal-gtk
      #   # xdg-desktop-portal-kde
      #   # xdg-desktop-portal-gnome
      # ];
    };

    # Auto update flatpak every boot with systemd
    # systemd.services.flatpak-update = {
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network-online.target" ];
    #   wants = [ "network-online.target" ];
    #   description = "Auto update flatpak every boot after network is online";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     ExecStart = ''${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive --system'';
    #   };
    # };
  };
}
