{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  mkTemplate = uri: {
    owner = user.name;
    content = ''
      MONGO_URL=${uri}
    '';
  };
  instances = [
    {
      ip = "10.88.245.1";
      name = "bareksa-mongo-stock-development";
      domain = "mongo-stock-development.bareksa.local";
      secretName = "bareksa/mongo/stock/development";
      socketAddress = "127.0.0.1:48910";
    }
    {
      ip = "10.88.245.2";
      name = "bareksa-mongo-stock-client-development";
      domain = "mongo-stock-client-development.bareksa.local";
      secretName = "bareksa/mongo/stock/client-development";
      socketAddress = "127.0.0.1:48911";
    }
    {
      ip = "10.88.245.3";
      name = "bareksa-mongo-stock-market-development";
      domain = "mongo-stock-market-development.bareksa.local";
      secretName = "bareksa/mongo/stock/market-development";
      socketAddress = "127.0.0.1:48912";
    }
  ];
in
{
  config = lib.mkIf config.profile.environment.bareksa.enable {
    sops = {
      secrets = builtins.listToAttrs (
        map (instance: {
          name = instance.secretName;
          value = {
            sopsFile = ../../secrets/bareksa.yaml;
            owner = user.name;
          };
        }) instances
      );
      templates = builtins.listToAttrs (
        map (instance: {
          name = instance.secretName;
          value = mkTemplate config.sops.placeholder."${instance.secretName}";
        }) instances
      );
    };

    virtualisation.oci-containers.containers = builtins.listToAttrs (
      map (instance: {
        name = instance.name;
        value = {
          image = "docker.io/quickbooks2018/mongo-gui:latest";
          autoStart = false;
          user = "${uid}:${gid}";
          extraOptions = [
            "--network=podman"
            "--ip=${instance.ip}"
          ];
          environment = {
            TZ = "Asia/Jakarta";
          };
          environmentFiles = [ config.sops.templates."${instance.secretName}".path ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      }) instances
    );

    systemd.sockets = builtins.listToAttrs (
      map (instance: {
        name = "podman-${instance.name}-proxy";
        value = {
          listenStreams = [ instance.socketAddress ];
          wantedBy = [ "sockets.target" ];
        };
      }) instances
    );

    systemd.services = builtins.listToAttrs (
      (map (instance: {
        name = "podman-${instance.name}";
        value = {
          unitConfig.StopWhenUnneeded = true;
        };
      }) instances)
      ++ (map (instance: {
        name = "podman-${instance.name}-proxy";
        value = {
          unitConfig = {
            Requires = [
              "podman-${instance.name}.service"
              "podman-${instance.name}-proxy.socket"
            ];
            After = [
              "podman-${instance.name}.service"
              "podman-${instance.name}-proxy.socket"
            ];
          };
          serviceConfig.ExecStart = ''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=15m ${instance.ip}:4321'';
        };
      }) instances)
    );

    services.nginx.virtualHosts = builtins.listToAttrs (
      map (instance: {
        name = instance.domain;
        value.locations = {
          "/" = {
            proxyPass = "http://${instance.socketAddress}";
            extraConfig = # nginx
              ''
                error_page 502 = @handle_502;
              '';
          };
          # loop back to Nginx until the container is started.
          "@handle_502".extraConfig = # nginx
            ''
              echo_sleep 1;
              echo_exec @loop;
            '';
          "@loop".proxyPass = "http://localhost:80";
        };
      }) instances
    );

    networking.extraHosts = lib.strings.concatStringsSep "\n" (
      map (instance: "127.0.0.1 ${instance.domain}") instances
    );
  };
}
