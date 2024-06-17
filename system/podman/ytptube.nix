{ config, lib, pkgs, ... }:
let
  name = "ytptube";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  gateway = "10.1.1.5";
  subnet = "10.1.1.4/30";
  ip = "10.1.1.6";
  ip-range = "10.1.1.6/30";
  image = "ghcr.io/arabcoders/${name}:latest";
  volume = "/nas/mediaserver/${name}";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:8081
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

    environment.etc."podman/${name}/ytdlp.json" = {
      # https://github.com/arabcoders/ytptube?tab=readme-ov-file#ytdlpjson-file
      source = (pkgs.formats.json { }).generate "config.json" {
        windowsfilenames = true;
        writesubtitles = true;
        writeinfojson = true;
        writethumbnail = true;
        writeautomaticsub = false;
        merge_output_format = "mkv";
        live_from_start = true;
        format_sort = [ "codec:abc:m4a" ];
        subtitleslangs = [ "en" ];
        postprocessors = [
          # this processor convert the downloaded thumbnail to jpg.
          {
            key = "FFmpegThumbnailsConvertor";
            format = "jpg";
          }
          # This processor convert subtitles to srt format.
          {
            key = "FFmpegSubtitlesConvertor";
            format = "srt";
          }
          # This processor embed metadata & info.json file into the final mkv file.
          {
            key = "FFmpegMetadata";
            add_infojson = true;
            add_metadata = true;
          }
          # This process embed subtitles into the final file if it doesn't have subtitles embedded
          {
            key = "FFmpegEmbedSubtitle";
            already_have_subtitle = false;
          }
        ];
      };
      mode = "0444";
    };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${volume}:/downloads"
        "/etc/podman/${name}/ytdlp.json:/config/ytdlp.json"
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=${name}"
      ];
    };
  };
}
