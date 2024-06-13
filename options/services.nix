{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile.services = {
    caddy.enable = mkEnableOption "caddy";
    cockpit.enable = mkEnableOption "cockpit";
  };
}
