{
  config,
  lib,
  pkgs,
  ...
}:
let
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
