{ config, lib, pkgs, ... }:
let
  name = "suwayomi";
  name-flaresolverr = "${name}-flaresolverr";
  domain = "manga.tigor.web.id";
  podman = config.profile.podman;
  suwayomi = podman.suwayomi;
  inherit (lib) mkIf;
  subnet = "10.1.1.8/29";
  gateway = "10.1.1.9";
  ip = "10.1.1.10";
  ip-flaresolverr = "10.1.1.11";
  ip-range = "10.1.1.10/29";
  image = "ghcr.io/suwayomi/tachidesk:latest";
  image-flaresolverr = "ghcr.io/flaresolverr/flaresolverr:latest";
  volume = "/nas/podman/suwayomi";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && suwayomi.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:4567
    '';

    systemd.services."create-${name}-network" = {
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "podman-${name}.service" ];
      script = ''${pkgs.podman}/bin/podman network exists ${name} || ${pkgs.podman}/bin/podman network create --gateway=${gateway} --subnet=${subnet} --ip-range=${ip-range} ${name}'';
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}
      chown -R ${uid}:${gid} ${volume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
        DOWNLOAD_AS_CBZ = "true";
        AUTO_DOWNLOAD_CHAPTERS = "true";
        AUTO_DOWNLOAD_EXCLUDE_UNREAD = "false";
        EXTENSION_REPOS = ''["https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"]'';
        MAX_SOURCES_IN_PARALLEL = "20";
        UPDATE_EXCLUDE_UNREAD = "false";
        UPDATE_EXCLUDE_STARTED = "false";
        UPDATE_INTERVAL = "6"; # 6 Hours interval
        UPDATE_MANGA_INFO = "true";
        FLARESOLVERR_ENABLED = "true";
        FLARESOLVERR_URL = "http://${ip-flaresolverr}:8191";
      };
      volumes = [
        "${volume}:/home/suwayomi/.local/share/Tachidesk"
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=${name}"
      ];
      dependsOn = [ "${name}-flaresolverr" ];
    };

    virtualisation.oci-containers.containers.${name-flaresolverr} = {
      image = image-flaresolverr;
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
      };
      extraOptions = [
        "--ip=${ip-flaresolverr}"
        "--network=${name}"
      ];
    };
  };
}
