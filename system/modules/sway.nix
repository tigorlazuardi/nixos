{ pkgs, ... }:
let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure/-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsetting-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'WhiteSur-dark'
        gsettings set $gnome_schema cursor-theme 'capitaine-cursors-white'
      '';
  };

  gnome-keyring-greetd-integration = pkgs.writeTextFile {
    name = "gnome-keyring-greetd-integration";
    destination = "/etc/pam.d/greetd";
    text = ''
      #%PAM-1.0
            
      auth       required     pam_securetty.so
      auth       requisite    pam_nologin.so
      auth       include      system-local-login
      auth       optional     pam_gnome_keyring.so
      account    include      system-local-login
      session    include      system-local-login
      session    optional     pam_gnome_keyring.so auto_start
    '';
  };
in
{
  programs.light.enable = true;
  users.users.tigor.extraGroups = [ "video" ];

  environment.systemPackages = with pkgs; [
    dbus-sway-environment
    configure-gtk
    gnome-keyring-greetd-integration

    alacritty
    sway
    wayland
    xdg-utils
    glib
    whitesur-icon-theme
    grim
    slurp
    wl-clipboard
    capitaine-cursors
    swayfx
  ];

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # programs.regreet.enable = true;
  # login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time -r --cmd ${pkgs.swayfx}/bin/sway";
        user = "tigor";
      };
      terminal = {
        vt = 7;
      };
    };
    # # clear bootlogs when greetd starts
    # serviceConfig = {
    #   Type = "idle";
    #   StandardInput = "tty";
    #   StandardOutput = "tty";
    #   StandardError = "journal";
    #   TTYReset = true;
    #   TTYVHangup = true;
    #   TTYVTDisallocate = true;
    # };
  };

  ### Securities

  # Allow swaylock to use PAM
  security.pam.services.swaylock = { };
  security.polkit.enable = true;

  # Save passwords, etc like wifi passwords
  services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = true;
}
