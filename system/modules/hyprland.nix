{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.xfconf.enable = true;
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
    programs.nautilus-open-any-terminal.enable = true;
    services.gnome.sushi.enable = true; # File previewer

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = with pkgs; [
        # Thunar Extended Support
        webp-pixbuf-loader # webp images
        poppler # .pdf filees
        ffmpegthumbnailer # video thumbnailer
        mcomix # comicbook archives
        nautilus # file manager

        gwenview

        # Hyprland Programs
        meson
        wayland-protocols
        wayland-utils
        wl-clipboard
        wlroots
        networkmanagerapplet
        dunst
        libnotify

        gnome-keyring
        seahorse

        greetd.tuigreet

        libappindicator-gtk2
        libappindicator
        catppuccin-sddm
      ];
    };

    programs.kdeconnect.enable = true;

    fonts.packages = with pkgs; [
      meslo-lgs-nf
      font-awesome
      roboto
    ];

    nixpkgs.overlays = [
      (self: super: {
        waybar = super.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        });
      })
    ];

    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    programs.file-roller.enable = true;

    services.greetd = lib.mkIf (cfg.displayManager == "tuigreet") {
      enable = true;
      restart = true;
      settings = {
        terminal = {
          vt = 5;
        };
        default_session = {
          command = ''tuigreet --remember --cmd "Hyprland"'';
          user = "tigor";
        };
      };
    };

    boot.kernelParams = [ "console=tty1" ];

    services.displayManager.sddm = lib.mkIf (cfg.displayManager == "sddm") {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
    };

    xdg.portal.xdgOpenUsePortal = true;

    services.libinput.enable = true;
  };
}
