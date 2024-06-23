{ config, lib, ... }:
let
  cfg = config.profile.services.photoprism;
  photoDir = "/nas/photos";
  domain = "photos.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    system.activationScripts.photoprism = ''
      mkdir -p ${photoDir}
      chown ${uid}:${gid} ${photoDir}
    '';

    users.groups.${user.name}.members = [ "photoprism" ];

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy 0.0.0.0:${toString config.services.photoprism.port}
    '';
    sops.secrets."photoprism/admin_password" = {
      sopsFile = ../../secrets/photoprism.yaml;
    };
    services.photoprism = {
      enable = true;
      port = 44999;
      originalsPath = photoDir;
      passwordFile = config.sops.secrets."photoprism/admin_password".path;
      settings = {
        PHOTOPRISM_ADMIN_USER = "hutasuhut";
      };
    };
  };
}
