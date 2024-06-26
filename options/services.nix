{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.profile.services = {
    caddy.enable = mkEnableOption "caddy";
    cockpit.enable = mkEnableOption "cockpit";
    forgejo.enable = mkEnableOption "forgejo";
    kavita.enable = mkEnableOption "kavita";
    samba.enable = mkEnableOption "samba";
    nextcloud.enable = mkEnableOption "nextcloud";
    syncthing.enable = mkEnableOption "syncthing";
    openvpn.enable = mkEnableOption "openvpn";
    stubby.enable = mkEnableOption "stubby";
    jellyfin.enable = mkEnableOption "jellyfin";
    jellyfin.jellyseerr.enable = mkOption {
      type = types.bool;
      default = config.profile.services.jellyfin.enable;
    };
    rust-motd.enable = mkEnableOption "rust-motd";
    wireguard.enable = mkEnableOption "wireguard";
    photoprism.enable = mkEnableOption "photoprism";
  };
}
