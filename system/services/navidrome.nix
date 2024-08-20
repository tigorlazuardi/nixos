{ config, lib, ... }:
let
  cfg = config.profile.services.navidrome;
  user = config.profile.user;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts."navidrome.tigor.web.id".extraConfig = ''
      reverse_proxy 0.0.0.0:${toString config.services.navidrome.settings.Port}
    '';

    users.groups.navidrome.members = [ user.name ];
    users.groups.${user.name}.members = [ "navidrome" ];

    services.navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/nas/Syncthing/Sync/Music";
      };
    };
  };
}
