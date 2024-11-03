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
    # ./dunst.nix
    ./bitwarden.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    # ./hyprshot.nix
    # hyprpaper seems to be broken with out of memory and failure to swap wallpapers correctly.
    # Use swww for now until the application is stable.
    # ./hyprpaper.nix
    ./pyprland.nix
    ./rofi.nix
    ./waybar.nix
    ./wlogout.nix
    ./grimblast.nix
    # ./swappy.nix
    ./alacritty.nix
    ./swayosd.nix
    ./swaync.nix
    ./ntfy-sh.nix
    ./gnome-keyring.nix
    ./kdeconnect.nix

    ./wallust
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

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

  };
}
