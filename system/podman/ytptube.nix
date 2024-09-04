{ config, lib, pkgs, ... }:
let
  name = "ytptube";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.0.4";
  image = "ghcr.io/arabcoders/${name}:latest";
  volume = "/nas/mediaserver/${name}";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  basic_auth = {
    username = "caddy/basic_auth/username";
    password = "caddy/basic_auth/password";
    template = "caddy/basic_auth";
  };
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    sops = {
      secrets =
        let
          opts = { };
        in
        {
          ${basic_auth.username} = opts;
          ${basic_auth.password} = opts;
        };
      templates = {
        ${basic_auth.template}.content = /*sh*/ ''
          YTPTUBE_USERNAME=${config.sops.placeholder.${basic_auth.username}}
          YTPTUBE_PASSWORD=${config.sops.placeholder.${basic_auth.password}}
        '';
      };
    };
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @require_auth not remote_ip private_ranges 

      basicauth @require_auth {
        {$YTPTUBE_USERNAME} {$YTPTUBE_PASSWORD}
      }

      reverse_proxy ${ip}:8081
    '';
    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}
      chown -R ${uid}:${gid} ${volume}
    '';

    systemd.services."caddy".serviceConfig = {
      EnvironmentFile = [ config.sops.templates.${basic_auth.template}.path ];
    };

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
      hostname = name;
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
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
