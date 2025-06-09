{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "jdownloader";
  cfg = config.profile.podman.jdownloader;
  inherit (lib) mkIf;
  ip = "10.88.1.1";
  image = "docker.io/jlesage/jdownloader-2:latest";
  volume = "/nas/podman/jdownloader";
  domain = "${name}.tigor.web.id";
  serviceAccount = name;
  socketAddress = "/run/podman/${name}.sock";

in
{
  config = mkIf cfg.enable {
    users = {
      groups.${serviceAccount} = { };
      users = {
        ${config.profile.user.name}.extraGroups = [ serviceAccount ];
        ${serviceAccount} = {
          isSystemUser = true;
          description = "Unprivileged system account for ${name} service";
          group = serviceAccount;
        };
        jellyfin = lib.mkIf config.services.jellyfin.enable {
          extraGroups = [ serviceAccount ];
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = false;
      locations = {
        "/" = {
          proxyPass = "http://unix:${socketAddress}";
          proxyWebsockets = true;
          extraConfig =
            # nginx
            ''
              auth_basic $auth_ip;
              # auth_request /authelia;
              # auth_request_set $target_url https://$http_host$request_uri;
              # auth_request_set $user $upstream_http_remote_user;
              # auth_request_set $email $upstream_http_remote_email;
              # auth_request_set $groups $upstream_http_remote_groups;
              # proxy_set_header Remote-User $user;
              # proxy_set_header Remote-Email $email;
              # proxy_set_header Remote-Groups $groups;

              proxy_read_timeout 2h;
              proxy_send_timeout 2h;
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
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads}
      chown ${serviceAccount}:${serviceAccount} ${volume}/{config,downloads}
    '';

    # sops.secrets."jdownloader/env".sopsFile = ../../secrets/jdownloader.yaml;
    systemd.services."podman-${name}" = {
      serviceConfig = {
        CPUWeight = 10;
        CPUQuota = "25%";
        IOWeight = 50;
      };
      unitConfig.StopWhenUnneeded = true;
    };

    systemd.sockets."podman-${name}-proxy" = {
      listenStreams = [ socketAddress ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.services."podman-${name}-proxy" = {
      unitConfig = {
        Requires = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
        After = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=8h ${ip}:5800";
      };
    };

    virtualisation.oci-containers.containers.${name} =
      let
        uid = toString config.users.users.${serviceAccount}.uid;
        gid = toString config.users.groups.${serviceAccount}.gid;
      in
      {
        inherit image;
        user = "${uid}:${gid}";
        hostname = name;
        autoStart = false;
        environment = {
          UMASK = "0002";
          TZ = "Asia/Jakarta";
          KEEP_APP_RUNNING = "1";
        };
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
        ];
        volumes = [
          "${volume}/config:/config:rw"
          "${volume}/downloads:/output:rw"
        ];
        # environmentFiles = [ config.sops.secrets."jdownloader/env".path ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
