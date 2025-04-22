{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.forgejo;
  domain = "git.tigor.web.id";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations =
        let
          anubisSettings = config.services.anubis.instances.forgejo.settings;
        in
        {
          "= /" = {
            extraConfig =
              #nginx
              ''
                if ($http_cookie !~ "gitea_incredible") {
                    rewrite ^(.*)$ /tigor redirect;
                }
              '';
            proxyPass = "http://unix:${anubisSettings.BIND}";
          };
          "/" = {
            proxyPass = "http://unix:${anubisSettings.BIND}";
          };
        };
    };

    services.anubis.instances.forgejo.settings.TARGET = "unix:///run/forgejo/forgejo.sock";

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    services.adguardhome.settings.user_rules = [ "192.168.100.5 ${domain}" ];

    services.forgejo = {
      enable = true;
      settings = {
        server = rec {
          PROTOCOL = "http+unix";
          DOMAIN = domain;
          HTTP_PORT = 443;
          ROOT_URL = "https://${DOMAIN}:${toString HTTP_PORT}";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        session.COOKIE_SECURE = true;
      };
    };

    sops.secrets."forgejo/runners/global" = {
      sopsFile = ../../secrets/forgejo.yaml;
    };

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances = {
        ${config.networking.hostName} = {
          enable = true;
          name = config.networking.hostName;
          url = config.services.forgejo.settings.server.ROOT_URL;
          tokenFile = config.sops.secrets."forgejo/runners/global".path;
          hostPackages = with pkgs; [
            bash
            coreutils
            curl
            gawk
            gitMinimal
            gnused
            nodejs
            wget
            typst
          ];
          settings = {
            runner = {
              capacity = 2;
              timeout = "1h";
            };
            cache = {
              enabled = true;
            };
            container = {
              privileged = true;
              # docker_host = "unix:///var/run/docker.sock";
              valid_volumes = [ "**" ];
            };
          };
          labels = [
            "docker:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
            "ubuntu:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
            "native:host"
          ];
        };
      };
    };
  };
}
