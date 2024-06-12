{ config, lib, ... }:
with lib;
let
  cfg = config.profile.sway;
in
{
  config = mkIf cfg.enable {
    services.swayosd = {
      enable = true;
    };
  };
}
