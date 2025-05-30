{
  config,
  lib,
  ...
}:
let
  name = "jdownloader";
  cfg = config.profile.podman.jdownloader;
  inherit (lib) mkIf;
  ip = "10.88.1.1";
  image = "docker.io/jlesage/jdownloader-2:latest";
  volume = "/nas/podman/jdownloader";
  domain = "${name}.tigor.web.id";
  serviceAccount = name;
in
{
  config = mkIf cfg.enable {
    users = {
      groups.${serviceAccount} = { };
      users = {
        ${config.profile.user.name}.extraGroups = [ serviceAccount ];
        ${serviceAccount} = {
          isSystemUser = true;
          description = "Unprivileged system account for ${name} service";
          group = serviceAccount;
        };
        jellyfin = lib.mkIf config.services.jellyfin.enable {
          extraGroups = [ serviceAccount ];
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:5800";
        proxyWebsockets = true;
        extraConfig = ''
          auth_basic $auth_ip;
          proxy_read_timeout 2h;
          proxy_send_timeout 2h;
        '';
      };
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads}
      chown ${serviceAccount}:${serviceAccount} ${volume}/{config,downloads}
    '';

    # sops.secrets."jdownloader/env".sopsFile = ../../secrets/jdownloader.yaml;
    systemd.services."podman-${name}".serviceConfig = {
      CPUWeight = 10;
      CPUQuota = "25%";
      IOWeight = 50;
    };

    virtualisation.oci-containers.containers.${name} =
      let
        uid = toString config.users.users.${serviceAccount}.uid;
        gid = toString config.users.groups.${serviceAccount}.gid;
      in
      {
        inherit image;
        user = "${uid}:${gid}";
        hostname = name;
        autoStart = true;
        environment = {
          UMASK = "0002";
          TZ = "Asia/Jakarta";
          KEEP_APP_RUNNING = "1";
        };
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
        ];
        volumes = [
          "${volume}/config:/config:rw"
          "${volume}/downloads:/output:rw"
        ];
        # environmentFiles = [ config.sops.secrets."jdownloader/env".path ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
