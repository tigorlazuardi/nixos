{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.forgejo;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts."git.tigor.web.id".extraConfig = ''
      reverse_proxy * unix//run/forgejo/forgejo.sock
    '';


    services.forgejo = {
      enable = true;
      settings = {
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = "git.tigor.web.id";
          HTTP_PORT = 443;
          ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        session.COOKIE_SECURE = true;
      };
    };

    sops.secrets."runner_token" = {
      sopsFile = ../../secrets/forgejo.yaml;
    };

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances = {
        ${config.networking.hostName} = {
          enable = true;
          name = config.networking.hostName;
          url = config.services.forgejo.settings.server.ROOT_URL;
          tokenFile = config.sops.secrets."runner_token".path;
          settings = {
            container = {
              privileged = true;
              # docker_host = "unix:///var/run/docker.sock";
              valid_volumes = [ "**" ];
            };
          };
          labels = [
            "docker:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
            "native:host"
          ];
        };
      };
    };
  };
}
