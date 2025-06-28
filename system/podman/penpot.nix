{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "penpot.tigor.web.id";
  dataDir = "/var/lib/penpot";
  publicURL = "https://${domain}";
  inherit (lib) mkIf;
  cfg = config.profile.services.penpot;
  ip = "10.88.9.1";
in
{
  config = mkIf cfg.enable {
    services.postgresql = {
      ensureDatabases = [ "penpot" ];
      ensureUsers = [
        {
          name = "penpot";
          ensureDBOwnership = true;
        }
      ];
    };
    services.redis.servers.penpot.enable = true;
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations."/" = {
        proxyPass = "http://${ip}:8080";
        # proxyPass = "http://unix:${config.systemd.socketActivations."podman-penpot-backend".socketAddress}";
        proxyWebsockets = true;
        extraConfig =
          #nginx
          ''
            client_max_body_size 512M;
          '';
      };
    };
    system.activationScripts.penpot = ''
      mkdir -p ${dataDir}/data/assets ${dataDir}/postgresql/data
    '';
    virtualisation.oci-containers.containers =
      let
        baseEnv = {
          TZ = "Asia/Jakarta";
          PENPOT_FLAGS = "disable-email-verification enable-smtp enable-prepl-server disable-secure-session-cookies";
        };
        envMaxBodySize = {
          PENPOT_HTTP_SERVER_MAX_BODY_SIZE = toString (1024 * 1024 * 32); # 32MB
          PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = toString (1024 * 1024 * 512); # 512 MB
        };
      in
      {
        penpot-frontend = {
          hostname = "penpot-frontend";
          image = "docker.io/penpotapp/frontend:latest";
          volumes = [ "${dataDir}/data/assets:/opt/data/assets" ];
          networks = [ "podman" ];
          environment = baseEnv // envMaxBodySize;
          labels = {
            "io.containers.autoupdate" = "registry";
          };
          extraOptions = [
            "--ip=${ip}"
          ];
        };
        penpot-backend = {
          hostname = "penpot-backend";
          image = "docker.io/penpotapp/backend:latest";
          volumes = [
            "${dataDir}/data/assets:/opt/data/assets"
          ];
          networks = [ "podman" ];
          environment =
            baseEnv
            // envMaxBodySize
            // {
              PENPOT_PUBLIC_URI = publicURL;
              PENPOT_SMTP_HOST = "mail.local";
              PENPOT_SMTP_PORT = "25";
              PENPOT_SMTP_TLS = "false";
              PENPOT_SMTP_SSL = "false";
              PENPOT_TELEMETRY_ENABLED = "false";
              PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
              PENPOT_DATABASE_USERNAME = "penpot";
              PENPOT_DATABASE_PASSWORD = "penpot";
              PENPOT_REDIS_URI = "redis://penpot-valkey/0";
              PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
              PENPOT_STORAGE_ASSETS_FS_DIRECTORY = "/opt/data/assets";
            };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
        penpot-exporter = {
          hostname = "penpot-exporter";
          image = "docker.io/penpotapp/exporter:latest";
          networks = [ "podman" ];
          environment = {
            PENPOT_PUBLIC_URI = "http://penpot-frontend:8080"; # Use internal host name.
            PENPOT_REDIS_URI = "redis://penpot-valkey/0";
          };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
        penpot-postgres = {
          hostname = "penpot-postgres";
          image = "docker.io/postgres:15";
          networks = [ "podman" ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
          podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
          volumes = [ "/var/lib/penpot/postgresql/data:/var/lib/postgresql/data" ];
          environment = {
            POSTGRES_DB = "penpot";
            POSTGRES_USER = "penpot";
            POSTGRES_PASSWORD = "penpot";
          };
          extraOptions = [
            ''--health-cmd=pg_isready -U penpot''
            ''--health-startup-cmd=pg_isready -U penpot''
            ''--health-startup-interval=100ms''
            ''--health-startup-retries=300'' # 30 second maximum wait.
          ];
        };
        penpot-valkey = {
          hostname = "penpot-valkey";
          image = "docker.io/valkey/valkey:8.1";
          networks = [ "podman" ];
          podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
          extraOptions = [
            ''--health-cmd=valkey-cli ping | grep PONG''
            ''--health-startup-cmd=valkey-cli ping | grep PONG''
            ''--health-startup-interval=100ms''
            ''--health-startup-retries=300'' # 30 second maximum wait.
          ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    systemd.services = {
      podman-penpot-frontend = {
        requires = [ "podman-penpot-backend.service" ];
        wants = [ "podman-penpot-backend.service" ];
      };
      podman-penpot-backend = {
        requires = [
          "podman-penpot-postgres.service"
          "podman-penpot-valkey.service"
        ];
        wants = [
          "podman-penpot-backend.service"
          "podman-penpot-valkey.service"
        ];
      };
      podman-penpot-exporter = {
        requires = [ "podman-penpot-valkey.service" ];
        wants = [ "podman-penpot-valkey.service" ];
      };
    };
  };
}
