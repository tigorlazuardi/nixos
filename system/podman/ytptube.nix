{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "ytptube";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.0.4";
  image = "ghcr.io/arabcoders/${name}:latest";
  volume = "/wolf/mediaserver/${name}";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
in
{
  config = mkIf podman.${name}.enable {
    users = {
      groups.${name}.gid = 972;
      users = {
        ${user.name}.extraGroups = [ name ];
        ${name} = {
          isSystemUser = true;
          description = "Unprivileged system account for ${name} service";
          group = name;
          uid = 977;
        };
        jellyfin = lib.mkIf config.services.jellyfin.enable {
          extraGroups = [ name ];
        };
      };

    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations."/" = {
        proxyPass = "http://unix:${config.systemd.socketActivations."podman-${name}".socketAddress}:";
        proxyWebsockets = true;
      };
    };

    system.activationScripts."podman-${name}" =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      ''
        mkdir -p ${volume}
        chown -R ${uid}:${gid} ${volume} /etc/podman/${name} 
      '';

    systemd.socketActivations."podman-${name}" = {
      host = ip;
      port = 8081;
      idleTimeout = "3h";
    };

    # systemd.services."podman-${name}".restartTriggers = [ webhook ];

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
        format_sort = [ "codec:avc:m4a" ];
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

    virtualisation.oci-containers.containers.${name} =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      {
        inherit image;
        hostname = name;
        autoStart = false;
        user = "${uid}:${gid}";
        environment = {
          TZ = "Asia/Jakarta";
          YTP_MAX_WORKERS = "4";
        };
        volumes = [
          "${volume}:/downloads"
          "/etc/podman/${name}:/config"
        ];
        extraOptions = [
          "--ip=${ip}"
          "--network=podman"
          "--umask=0002"
        ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
