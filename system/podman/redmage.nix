{ config, lib, ... }:
let
  name = "redmage";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.0.2";
  image = "git.tigor.web.id/tigor/redmage:latest";
  rootVolume = "/nas/redmage";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://unix:${config.services.anubis.instances.redmage.settings.BIND}";
        };
      };
    };

    services.anubis.instances.redmage.settings.TARGET = "http://${ip}:8080";

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}/db
      mkdir -p ${rootVolume}/images
      chown ${uid}:${gid} ${rootVolume} ${rootVolume}/db ${rootVolume}/images
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${rootVolume}/db:/app/db"
        "${rootVolume}/images:/app/downloads"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

}
