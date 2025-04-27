{
  lib,
  config,
  ...
}:
let
  cfg = config.profile.services.homepage-dashboard;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets."homepage/env" = {
      sopsFile = ../../secrets/homepage.yaml;
    };
    services.homepage-dashboard = {
      enable = true;
      settings = {
        title = "Tigor's Homeserver";
        description = "A site for my personal server";
        startUrl = "https://tigor.web.id";
      };
      widgets = [
        {
          resources = {
            label = "System";
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
            units = "metric";
            network = true;
            disk = [
              "/"
              "/nas"
            ];
          };
        }
      ];
      allowedHosts = "tigor.web.id";
      environmentFile = config.sops.secrets."homepage/env".path;
    };

    services.nginx.virtualHosts."tigor.web.id" = {
      forceSSL = true;
      useACMEHost = "tigor.web.id";
      locations."/" = {
        proxyPass = "http://0.0.0.0:${toString config.services.homepage-dashboard.listenPort}";
        proxyWebsockets = true;
      };
    };
  };
}
