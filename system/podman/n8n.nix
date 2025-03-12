{
  config,
  lib,
  ...
}:
let
  name = "n8n";
  cfg = config.profile.podman.${name};
  inherit (lib) mkIf;
  ip = "10.88.41.1";
  image = "docker.n8n.io/n8nio/n8n:latest";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  rootVolume = "/nas/podman/n8n";
in
{
  config = mkIf (cfg.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:5678";
        extraConfig = # nginx
          ''
            client_max_body_size 16M;
          '';
      };
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}
      chown ${uid}:${gid} ${rootVolume}
    '';

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [ "${rootVolume}:/home/node/.n8n" ];
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
