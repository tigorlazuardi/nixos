{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "cctv-ivms4200";
  cfg = config.profile.podman.cctv-ivms4200;
  inherit (lib) mkIf;
  ip = "10.88.1.2";
  image = "docker.io/bkjaya1952/docker-ivms4200-linux";
  domain = "cctv.tigor.web.id";
  volume = "/var/lib/podman/${name}";
  socketAddress = "/run/podman/${name}.sock";
in
{
  config = mkIf cfg.enable {
    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads}
    '';
    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = false;
      volumes = [
        "${volume}/config:/WinApp"
        "${volume}/downloads:/Downloads"
      ];
      environment = {
        TZ = "Asia/Jakarta";
        UMASK = "0002";
      };
      extraOptions = [
        "--ip=${ip}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations = {
        "/" = {
          proxyPass = "http://unix:${socketAddress}";
          proxyWebsockets = true;
        };
      };
    };

    systemd.services."podman-${name}" = {
      unitConfig.StopWhenUnneeded = true;
      serviceConfig.ExecStartPost = [ "${pkgs.waitport}/bin/waitport ${ip} 8080" ];
    };

    systemd.sockets."podman-${name}-proxy" = {
      listenStreams = [ socketAddress ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.services."podman-${name}-proxy" = {
      unitConfig = {
        Requires = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
        After = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5m ${ip}:8080";
      };
    };
  };
}
