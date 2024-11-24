{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "soulseek";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.60.80";
  image = "ghcr.io/fletchto99/nicotine-plus-docker:latest";
  rootVolume = "/nas/podman/soulseek";
  rootVolumeMusic = "/nas/Syncthing/Sync/Music";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @require_auth not remote_ip private_ranges 

      basic_auth @require_auth {
        {$AUTH_USERNAME} {$AUTH_PASSWORD}
      }

      reverse_proxy ${ip}:6080
    '';

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:6080";
        proxyWebsockets = true;
      };
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}/{config,downloads,incomplete}
      chown ${uid}:${gid} ${rootVolume} ${rootVolume}/{config,downloads,incomplete}
    '';

    # Soulseek only autoscans on startup
    #
    # Once a day at 4am, restart the container to trigger a rescan
    systemd =
      let
        serviceName = "podman-${name}-autorestart";
      in
      {
        services.${serviceName} = {
          description = "Podman container ${name} autorestart";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.podman}/bin/podman restart ${name}";
          };
        };
        timers.${serviceName} = {
          description = "Podman container ${name} autorestart";
          timerConfig = {
            OnCalendar = "*-*-* 04:00:00";
          };
          wantedBy = [ "timers.target" ];
        };
      };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
        PUID = uid;
        PGID = gid;
      };
      volumes = [
        "${rootVolume}/config:/config"
        "${rootVolume}/incomplete:/data/incomplete_downloads"
        "${rootVolumeMusic}:/data/shared"
      ];
      ports = [ "2234-2239:2234-2239" ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
        "--security-opt=seccomp=unconfined"
        "--device=/dev/dri:/dev/dri"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

}
