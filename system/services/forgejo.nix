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
    services.caddy.virtualHosts."git.tigor.web.id".extraConfig = ''
      @home_not_login {
            not header_regexp Cookie gitea_incredible
            path /
      }
      redir @home_not_login /Tigor
      reverse_proxy * unix//run/forgejo/forgejo.sock
    '';

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
