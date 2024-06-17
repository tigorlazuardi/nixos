{ config, lib, ... }:
let
  cfg = config.profile.services.jellyfin;
  dataDir = "/nas/mediaserver/jellyfin";
  domain = "jellyfin.tigor.web.id";
  inherit (lib) mkIf;
  username = config.profile.user.name;
in
{
  config = mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "jellyfin" ];
    users.users.jellyfin.extraGroups = [ username ];
    system.activationScripts.jellyfin-prepare = ''
      mkdir -p ${dataDir}
      chmod -R 0777 /nas/mediaserver
    '';
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy 0.0.0.0:8096
    '';
    services.jellyfin = {
      enable = true;
      inherit dataDir;
    };
  };
}
