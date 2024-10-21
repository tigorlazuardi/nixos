{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib) mkIf;
  inherit (lib.meta) getExe;
  secretKey = "gnome-keyring/${config.home.username}";
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gnome.gnome-keyring ];

    sops.secrets.${secretKey} = { };
    wayland.windowManager.hyprland.settings.exec-once =
      let
        scriptFile = getExe (
          pkgs.writeShellScriptBin "gnome-keyring.sh" # sh
            ''
              cat "${config.sops.secrets.${secretKey}.path}" | gnome-keyring-daemon --unlock
              gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
            ''
        );
      in
      [ ''${scriptFile}'' ];
  };
}
