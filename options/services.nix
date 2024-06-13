{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile.services = {
    caddy.enable = mkEnableOption "caddy";
    cockpit.enable = mkEnableOption "cockpit";
    forgejo.enable = mkEnableOption "forgejo";
    kavita.enable = mkEnableOption "kavita";
    samba.enable = mkEnableOption "samba";
  };
}