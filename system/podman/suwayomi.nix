{ config, lib, ... }:
let
  name = "suwayomi";
  name-flaresolverr = "${name}-flaresolverr";
  domain = "manga.tigor.web.id";
  podman = config.profile.podman;
  suwayomi = podman.suwayomi;
  inherit (lib) mkIf;
  ip = "10.88.0.5";
  ip-flaresolverr = "10.88.0.6";
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

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}
      chown ${uid}:${gid} ${volume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
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
        "--network=podman"
      ];
      dependsOn = [ "${name}-flaresolverr" ];
    };

    virtualisation.oci-containers.containers.${name-flaresolverr} = {
      image = image-flaresolverr;
      hostname = name-flaresolverr;
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
      };
      extraOptions = [
        "--ip=${ip-flaresolverr}"
        "--network=podman"
      ];
    };
  };
}
