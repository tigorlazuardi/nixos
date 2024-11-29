{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.forgejo;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."git.tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/robots.txt".extraConfig = # nginx
          ''
            add_header Content-Type text/plain;
            return 200 "User-agent: *\nDisallow: /";
          '';
        "= /" = {
          extraConfig =
            #nginx
            ''
              if ($http_cookie !~ "gitea_incredible") {
                  rewrite ^(.*)$ /Tigor redirect;
              }
            '';
          proxyPass = "http://unix:/run/forgejo/forgejo.sock";
        };
        "/" = {
          proxyPass = "http://unix:/run/forgejo/forgejo.sock";
          extraConfig =
            # nginx
            ''
              if ($http_user_agent ~* (netcrawl|npbot|malicious|meta-externalagent|Bytespider|DotBot|Googlebot)) {
                  return 403;
              }
            '';
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ "git.tigor.web.id" ];

    services.forgejo = {
      enable = true;
      settings = {
        server = rec {
          PROTOCOL = "http+unix";
          DOMAIN = "git.tigor.web.id";
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
