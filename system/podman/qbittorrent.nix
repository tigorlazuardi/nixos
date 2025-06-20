{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "qbittorrent";
  domain = "${name}.tigor.web.id";
  altDomain = "vuetorrent.tigor.web.id";
  podman = config.profile.podman;
  qbittorrent = podman.qbittorrent;
  inherit (lib) mkIf;
  inherit (lib.strings) optionalString;
  ip = "10.88.0.7";
  image = "lscr.io/linuxserver/qbittorrent:latest";
  volume = "/nas/torrents";
  user = config.profile.user;
  serviceAccount = name;
in
{
  config = mkIf qbittorrent.enable {
    profile.services.ntfy-sh.client.settings.subscribe = [ { topic = "qbittorrent"; } ];
    users = {
      groups.${serviceAccount}.gid = 974;
      users = {
        ${user.name}.extraGroups = [ serviceAccount ];
        ${serviceAccount} = {
          isSystemUser = true;
          description = "Unpriviledged system account for qbittorrent service";
          group = serviceAccount;
          uid = 979;
        };
        jellyfin = lib.mkIf config.services.jellyfin.enable {
          extraGroups = [ serviceAccount ];
        };
      };
    };
    services.nginx.virtualHosts =
      let
        opts = {
          useACMEHost = "tigor.web.id";
          enableAuthelia = true;
          autheliaLocations = [ "/" ];
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${ip}:8080";
            proxyWebsockets = true;
          };
        };
      in
      {
        "${domain}" = opts;
        "${altDomain}" = opts;
      };

    system.activationScripts."podman-${name}" =
      let
        uid = toString config.users.users.${serviceAccount}.uid;
        gid = toString config.users.groups.${serviceAccount}.gid;
      in
      ''
        mkdir -p ${volume}/{config,downloads,progress,watch}
        chown ${uid}:${gid} ${volume} ${volume}/{config,downloads,progress,watch}
      '';

    sops = {
      secrets =
        let
          opts = {
            sopsFile = ../../secrets/ntfy.yaml;
          };
        in
        {
          "ntfy/tokens/homeserver" = opts;
        };
      templates = {
        "qbittorrent-ntfy-env".content = # sh
          ''
            NTFY_TOKEN=${config.sops.placeholder."ntfy/tokens/homeserver"}
          '';
      };
    };
    systemd.services."podman-${name}".serviceConfig = {
      CPUWeight = 10;
      CPUQuota = "25%";
      IOWeight = 50;
    };

    virtualisation.oci-containers.containers.${name} =
      let
        finish-notify-script = pkgs.writeScriptBin "notify-finish.sh" (
          optionalString config.services.ntfy-sh.enable # sh
            ''
              #!/bin/bash
              # $1 = %N  | Torrent Name
              # $2 = %L  | Category
              # $3 = %G  | Tags
              # $4 = %F  | Content Path
              # $5 = %R  | Root Path
              # $6 = %D  | Save Path
              # $7 = %C  | Number of files
              # $8 = %Z  | Torrent Size
              # $9 = %T  | Current Tracker
              # $10 = %I | Info Hash v1
              # $11 = %J | Info Hash v2
              # $12 = %K | Torrent ID

              size=$(echo $8 | numfmt --to=iec)
              curl -X POST \
                -H "Authorization: Bearer $NTFY_TOKEN" \
                -H "X-Title: $1" \
                -H "X-Tags: white_check_mark,$2" \
                -d "Number of Files: $7, Size: $size" \
                https://ntfy.tigor.web.id/qbittorrent?priority=4
            ''
        );
        start-notify-script = pkgs.writeScriptBin "notify-start.sh" (
          optionalString config.services.ntfy-sh.enable # sh
            ''
              #!/bin/bash
              curl -X POST \
                -H "Authorization: Bearer $NTFY_TOKEN" \
                -H "X-Title: $1" \
                -H "X-Tags: rocket,$2" \
                -d "Starts downloading" \
                https://ntfy.tigor.web.id/qbittorrent
            ''
        );
        uid = toString config.users.users.${serviceAccount}.uid;
        gid = toString config.users.groups.${serviceAccount}.gid;
      in
      {
        inherit image;
        hostname = name;
        autoStart = true;
        user = "${uid}:${gid}";
        environment = {
          PUID = uid;
          PGID = gid;
          TZ = "Asia/Jakarta";
          WEBUI_PORT = "8080";
          TORRENTING_PORT = "6881";
        };
        volumes = [
          "${volume}/config:/config"
          "${volume}/downloads:/downloads"
          "${volume}/progress:/progress"
          "${volume}/watch:/watch"
          "${finish-notify-script}/bin/notify-finish.sh:/bin/notify-finish"
          "${start-notify-script}/bin/notify-start.sh:/bin/notify-start"
          "${pkgs.vuetorrent}/share/vuetorrent:/webui/vuetorrent:ro"
        ];
        ports = [
          "6881:6881"
          "6881:6881/udp"
        ];
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
        ];
        environmentFiles = [ config.sops.templates."qbittorrent-ntfy-env".path ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
