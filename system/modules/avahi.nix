# Avahi is service discovery service. Depending on environment
# this may preferred to be disabled.

{ config, lib, ... }:
let
  cfg = config.profile.avahi;
in
{
  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
  };
}
