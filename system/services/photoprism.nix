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

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://0.0.0.0:${toString config.services.photoprism.port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

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
        PHOTOPRISM_INDEX_SCHEDULE = "0 3 * * *";
        PHOTOPRISM_DEFAULT_TIMEZONE = "Asia/Jakarta";
        PHOTOPRISM_SITE_AUTHOR = "Tigor Hutasuhut";
        PHOTOPRISM_FACE_CLUSTER_CORE = "3";
      };
    };
  };
}
