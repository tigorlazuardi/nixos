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
        "/robots.txt".extraConfig = # nginx
          ''
            add_header Content-Type text/plain;
            return 200 "User-agent: *\nDisallow: /";
          '';
        "/" = {
          proxyPass = "http://${ip}:8080";
          extraConfig =
            # nginx
            ''
              if ($http_user_agent ~* (netcrawl|npbot|malicious|meta-externalagent|Bytespider|DotBot|Googlebot)) {
                  return 403;
              }
            '';
        };
      };
    };

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
