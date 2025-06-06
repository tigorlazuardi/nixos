{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profile.vial;
in
{
  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      vial
      via
      qmk-udev-rules
    ];

    environment.systemPackages = with pkgs; [
      vial
      via
      qmk
    ];

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
