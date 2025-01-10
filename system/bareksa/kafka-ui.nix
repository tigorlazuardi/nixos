{
  config,
  lib,
  pkgs,
  ...
}:
let
  ip = "10.88.244.1";
  name = "bareksa-kafka-ui";
  domain = "kafka-ui.bareksa.local";
  settings = {
    kafka = {
      clusters = [
        {
          name = "Bareksa Development";
          bootstrapServers = "kafka.dev.bareksa.local:9093";
        }
      ];
    };
  };
in
{
  config = lib.mkIf config.profile.environment.bareksa.enable {
    virtualisation.oci-containers.containers."${name}" = {
      image = "provectuslabs/kafka-ui:latest";
      hostname = name;
      autoStart = true;
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];

      environment = {
        TZ = "Asia/Jakarta";
        SPRING_CONFIG_ADDITIONAL-LOCATION = "/config.yaml";
      };

      volumes = [
        "${(pkgs.formats.yaml { }).generate "config.yaml" settings}:/config.yaml"
      ];
    };

    services.nginx.virtualHosts."${domain}".locations = {
      "/" = {
        proxyPass = "http://${ip}:8080";
      };
    };

    networking.extraHosts = "127.0.0.1 ${domain}";
  };
}
