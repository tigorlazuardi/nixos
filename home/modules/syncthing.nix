{ lib, config, ... }:
let
  cfg = config.profile.syncthing;
in
{
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = false;
    };
  };
}
