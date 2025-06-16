{ config, lib, ... }:
let
  podman = config.profile.podman;
  qbittorrent = podman.servarr.qbittorrent;
  name = "qbittorrent-servarr";
  ip = "10.88.2.2";
  image = "lscr.io/linuxserver/qbittorrent:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/qbittorrent";
  mediaVolume = "${root}/data/torrents";
  domain = "qbittorrent-servarr.tigor.web.id";
  user = config.profile.user;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && qbittorrent.enable) {
    services.nginx.virtualHosts =
      let
        opts = {
          proxyPass = "http://${ip}:8080";
          proxyWebsockets = true;
        };
      in
      {
        "${domain}" = {
          useACMEHost = "tigor.web.id";
          enableAuthelia = true;
          autheliaLocations = [ "/" ];
          forceSSL = true;
          locations."/" = opts;
        };
        "qbittorrent.servarr.local".locations."/" = opts;
      };

    users = {
      groups.${name}.gid = 902;
      users = {
        ${user.name}.extraGroups = [ name ];
        ${name} = {
          isSystemUser = true;
          description = "Unpriviledged system account for qbittorrent service";
          group = name;
          uid = 902;
        };
        jellyfin = lib.mkIf config.services.jellyfin.enable {
          extraGroups = [ name ];
        };
      };
    };

    system.activationScripts."podman-${name}" =
      let

        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      ''
        mkdir -p ${configVolume} ${mediaVolume}
        chown -R ${uid}:${gid} ${mediaVolume} ${configVolume}
      '';

    systemd.services."podman-${name}".serviceConfig = {
      CPUWeight = 10;
      CPUQuota = "25%";
      IOWeight = 50;
    };

    virtualisation.oci-containers.containers.${name} =
      let

        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
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
          TORRENTING_PORT = "6882";
        };
        volumes = [
          "${configVolume}:/config"
          "${mediaVolume}:/data/torrents"
        ];
        ports = [
          "6882:6882"
          "6882:6882/udp"
        ];
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
        ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
