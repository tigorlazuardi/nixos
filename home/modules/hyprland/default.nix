{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  imports = [
    ./bitwarden.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./pyprland.nix
    ./rofi.nix
    ./waybar.nix
    ./wlogout.nix
    ./grimblast.nix
    ./ags.nix
    ./alacritty.nix
    ./swayosd.nix
    ./swaync.nix
    ./ntfy-sh.nix
    ./kdeconnect.nix
    ./walker.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cliphist
      qalculate-gtk
      pavucontrol
      pasystray

      graphicsmagick
      swayosd
      image-roll # image viewer
    ];

    # home.pointerCursor = {
    #   name = "Adwaita";
    #   package = pkgs.adwaita-icon-theme;
    #   size = 24;
    #   x11 = {
    #     enable = true;
    #     defaultCursor = "Adwaita";
    #   };
    # };

  };
}
