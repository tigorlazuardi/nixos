{ config, lib, ... }:
let
  cfg = config.profile.services.flaresolverr;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      port = 8191;
    };
  };
}
