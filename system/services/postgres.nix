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
      autoStart = true;
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
    services.nginx.virtualHosts = {
      "${domain}" = {
        useACMEHost = "tigor.web.id";
        forceSSL = true;
        enableAuthelia = true;
        autheliaLocations = [ "/" ];
        locations."/".proxyPass = "http://${ip}:3000";
      };
      "db.local" = {
        locations."/".proxyPass = "http://${ip}:3000";
      };
    };
  };
}
