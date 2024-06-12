{ config, lib, ... }:
let
  cfg = config.profile.security.sudo-rs;
in
{
  config = lib.mkIf cfg.enable {
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
      wheelNeedsPassword = cfg.wheelNeedsPassword;
    };
  };
}
