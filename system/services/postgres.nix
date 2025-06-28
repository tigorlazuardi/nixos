{
  config,
  lib,
  ...
}:
let
  cfg = config.services.postgresql;
  domain = "db.tigor.web.id";
  data = "/var/lib/dbgate";
  ip = "10.88.10.10";
  name = "db-gate";
in
{
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      identMap = ''
        postgres root postgres
      '';
    };
    system.activationScripts."podman-${name}" = # sh
      ''
        mkdir -p ${data}
      '';
    virtualisation.oci-containers.containers."${name}" = {
      image = "docker.io/dbgate/dbgate:latest";
      hostname = name;
      volumes = [
        "${data}:/root/.dbgate"
        "/run/postgresql:/var/run/postgresql"
      ];
      networks = [ "podman" ];
      extraOptions = [ "--ip=${ip}" ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
    systemd.socketActivations."podman-${name}" = {
      host = ip;
      port = 3000;
    };
    services.nginx.virtualHosts =
      let
        inherit (config.systemd.socketActivations."podman-${name}") socketAddress;
        pp = "http://unix:${socketAddress}";
      in
      {
        "${domain}" = {
          useACMEHost = "tigor.web.id";
          forceSSL = true;
          enableAuthelia = true;
          autheliaLocations = [ "/" ];
          locations."/".proxyPass = pp;
        };
        "db.local" = {
          locations."/".proxyPass = pp;
        };
      };
  };
}
