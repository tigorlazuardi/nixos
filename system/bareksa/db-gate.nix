{
  config,
  lib,
  ...
}:
let
  ip = "10.88.244.2";
  name = "bareksa-db-gate";
  domain = "db.bareksa.local";
  volume = "/var/lib/dbgate";
in
{
  config = lib.mkIf config.profile.environment.bareksa.enable {
    system.activationScripts."podman-${name}" = # sh
      ''
        mkdir -p ${volume}
      '';
    virtualisation.oci-containers.containers."${name}" = {
      image = "docker.io/dbgate/dbgate:latest";
      hostname = name;
      volumes = [ "${volume}:/root/.dbgate" ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
    services.nginx.virtualHosts."${domain}".locations."/" = {
      proxyPass = "http://unix:/${config.systemd.socketActivations."podman-${name}".socketAddress}";
      proxyWebsockets = true;
    };

    systemd.socketActivations."podman-${name}" = {
      host = ip;
      port = 3000;
    };
    networking.extraHosts = "127.0.0.1 ${domain}";
  };
}
