{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "morphos";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.88.2";
  image = "ghcr.io/danvergara/morphos-server:latest";
  domain = "${name}.tigor.web.id";
  socketAddress = "/run/podman/${name}.sock";
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations."/" = {
        proxyPass = "http://unix:${socketAddress}";
        extraConfig = # nginx
          ''
            client_max_body_size 100M;
          '';
      };
    };

    systemd.services."podman-${name}" = {
      unitConfig.StopWhenUnneeded = true;
      serviceConfig.ExecStartPost = "${pkgs.waitport}/bin/waitport ${ip} 8080";
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
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=15m ${ip}:8080";
      };
    };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = false;
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [ "/tmp:/tmp" ];
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
