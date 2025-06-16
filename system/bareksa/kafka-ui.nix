{
  config,
  lib,
  pkgs,
  ...
}:
let
  ip = "10.88.244.1";
  name = "bareksa-kafka";
  domain = "kafka.bareksa.local";
  settings = {
    kafka = {
      clusters = [
        {
          name = "Bareksa Development";
          bootstrapServers = "kafka.dev.bareksa.local:9093,kafka.dev.bareksa.local:9094,kafka.dev.bareksa.local:9095";
        }
        {
          name = "Bareksa Production";
          bootstrapServers = "192.168.50.102:9092,192.168.50.103:9092,192.168.50.104:9092";
          readOnly = true;
        }
        {
          name = "Bareksa Aiven";
          bootstrapServers = config.sops.placeholder."bareksa/aiven/kafka/host";
          readOnly = true;
          properties = {
            security.protocol = "SSL";
            ssl.truststore.location = "/aiven.keystore.jks";
            ssl.truststore.password = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
            ssl.keystore.type = "PKCS12";
            ssl.keystore.location = "/aiven.bareksa.p12";
            ssl.keystore.password = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
          };
        }
      ];
    };
  };
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = lib.mkIf config.profile.environment.bareksa.enable {
    sops = {
      secrets = {
        "aiven.bareksa.p12" = {
          format = "binary";
          sopsFile = ../../secrets/bareksa/aiven.bareksa.p12;
          owner = user.name;
        };
        "aiven.keystore.jks" = {
          format = "binary";
          sopsFile = ../../secrets/bareksa/aiven.truststore.jks;
          owner = user.name;
        };
        "bareksa/aiven/kafka/truststore/password" = {
          sopsFile = ../../secrets/bareksa.yaml;
          owner = user.name;
        };
        "bareksa/aiven/kafka/host" = {
          sopsFile = ../../secrets/bareksa.yaml;
          owner = user.name;
        };
      };

      templates."kafka.config.yaml" = {
        owner = user.name;
        content = builtins.readFile ((pkgs.formats.yaml { }).generate "kafka.config.yaml" settings);
      };
    };

    virtualisation.oci-containers.containers."${name}" = {
      image = "provectuslabs/kafka-ui:latest";
      user = "${uid}:${gid}";
      hostname = name;
      # this will be activated on demand via systemd-socket-activation.
      # Meaning when kafka.bareksa.local is accessed, the container will be started.
      autoStart = false;
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];

      environment = {
        TZ = "Asia/Jakarta";
        SPRING_CONFIG_ADDITIONAL-LOCATION = "/config.yaml";
      };

      volumes = [
        "${config.sops.templates."kafka.config.yaml".path}:/config.yaml"
        "${config.sops.secrets."aiven.bareksa.p12".path}:/aiven.bareksa.p12"
        "${config.sops.secrets."aiven.keystore.jks".path}:/aiven.keystore.jks"
      ];
    };
    systemd.socketActivations."podman-${name}" = {
      host = ip;
      port = 8080;
    };

    services.nginx.virtualHosts."${domain}".locations = {
      "/" = {
        proxyPass = "http://unix:${config.systemd.socketActivations."podman-${name}".socketAddress}";
      };
    };

    # 127.0.0.1 ${domain} will force browsers to resolve kafka.bareksa.local to
    # nginx, and nginx will proxy the request to the Kafka UI container.
    networking.extraHosts = ''
      127.0.0.1 ${domain}
      192.168.50.102 kafka-host-1 kafka-cluster-jkt-1
      192.168.50.103 kafka-host-2 kafka-cluster-jkt-2
      192.168.50.104 kafka-host-3 kafka-cluster-jkt-3
    '';
  };
}
