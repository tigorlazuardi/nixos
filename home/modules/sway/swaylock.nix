{ config, lib, ... }:
with lib;
let
  cfg = config.profile.sway;
in
{
  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        show-failed-attempts = true;
      };
    };
  };
}
