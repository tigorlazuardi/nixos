{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
in
{
  config = lib.mkIf cfg.enable {
    programs.xfconf.enable = true;
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    programs.uwsm = {
      enable = true;
    };
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
    services.gnome.sushi.enable = true; # File previewer
    services.gnome.gnome-keyring.enable = true; # Keyring management

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

        kdePackages.gwenview

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

        # greetd.tuigreet

        # libappindicator-gtk2
        libappindicator

        # theme packages
        (catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "compact";
          variant = "mocha";
        })
      ];
    };

    programs.kdeconnect.enable = true;

    # Fix unpopulated MIME menus in dolphin
    environment.etc."/xdg/menus/applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    programs.file-roller.enable = true;

    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = ../../assets/kemonomimi_fapl2r7n2ync1.jpeg;
          fit = "Cover";
        };
      };
    };

    services.greetd = {
      enable = true;
      restart = true;
      settings.default_session =
        let
          hyprlandConfig =
            pkgs.writeText "hyprlandGreeter.conf"
              # hyprlang
              ''
                exec-once = ${getExe config.programs.regreet.package}; hyprctl dispatch exit
                misc {
                    disable_hyprland_logo = true
                    disable_splash_rendering = true
                }
              '';
        in
        {
          command = "Hyprland --config ${hyprlandConfig}";
        };
    };

    services.libinput.enable = true;

    # unlock GPG keyring on login
    security.pam.services.greetd = {
      gnupg.enable = true;
      enableGnomeKeyring = true;
    };
  };
}
