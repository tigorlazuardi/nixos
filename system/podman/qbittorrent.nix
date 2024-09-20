{ config, lib, pkgs, ... }:
let
  name = "qbittorrent";
  domain = "${name}.tigor.web.id";
  podman = config.profile.podman;
  qbittorrent = podman.qbittorrent;
  inherit (lib) mkIf;
  inherit (lib.strings) optionalString;
  ip = "10.88.0.7";
  image = "lscr.io/linuxserver/qbittorrent:latest";
  volume = "/nas/torrents";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && qbittorrent.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:8080
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads,progress,watch}
      chown ${uid}:${gid} ${volume} ${volume}/{config,downloads,progress,watch}
    '';


    sops = {
      secrets =
        let
          opts = { sopsFile = ../../secrets/ntfy.yaml; };
        in
        {
          "ntfy/tokens/homeserver" = opts;
        };
      templates = {
        "qbittorrent-ntfy-env".content = /*sh*/ ''
          NTFY_TOKEN=${config.sops.placeholder."ntfy/tokens/homeserver"}
        '';
      };
    };

    virtualisation.oci-containers.containers.${name} =
      let
        finish-notify-script = pkgs.writeScriptBin "notify-finish.sh" (optionalString config.services.ntfy-sh.enable /*sh*/ ''
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
        '');
        start-notify-script = pkgs.writeScriptBin "notify-start.sh" (optionalString config.services.ntfy-sh.enable /*sh*/ ''
          #!/bin/bash
          curl -X POST \
            -H "Authorization: Bearer $NTFY_TOKEN" \
            -H "X-Title: $1" \
            -H "X-Tags: rocket,$2" \
            -d "Starts downloading" \
            https://ntfy.tigor.web.id/qbittorrent
        '');
      in
      {
        inherit image;
        hostname = name;
        autoStart = true;
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
        ];
        ports = [
          "6881:6881"
          "6881:6881/udp"
        ];
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
        ];
        environmentFiles = [
          config.sops.templates."qbittorrent-ntfy-env".path
        ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}

