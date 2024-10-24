{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprland = config.profile.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf hyprland.enable {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    systemd.user.services.kdeconnect-indicator.Service.ExecStart = lib.mkForce ''
      ${pkgs.dbus}/bin/dbus-launch ${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator
    '';

    systemd.user.services.kdeconnect.Service.ExecStart = lib.mkForce ''
      ${pkgs.dbus}/bin/dbus-launch ${pkgs.kdePackages.kdeconnect-kde}/libexec/kdeconnectd
    '';
  };
}
