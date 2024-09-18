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
          "ntfy/tokens/homeserver" = { sopsFile = ../../secrets/ntfy.yaml; };
        };
      templates = {
        ${basic_auth.template}.content = /*sh*/ ''
          YTPTUBE_USERNAME=${config.sops.placeholder.${basic_auth.username}}
          YTPTUBE_PASSWORD=${config.sops.placeholder.${basic_auth.password}}
        '';
        "ytptube/webhooks.json" = mkIf config.services.ntfy-sh.enable {
          content = builtins.readFile ((pkgs.formats.json { }).generate "webhooks.json" [
            {
              name = "NTFY Webhook";
              on = [ "added" "completed" "error" "not_live" ];
              request = {
                url = "https://ntfy.tigor.web.id/ytptube?tpl=1&t=%7B%7B.title%7D%7D&m=%5B%7B%7B%20.folder%20%7D%7D%5D%20Download%20%7B%7B%20.status%20%7D%7D&Click=https%3A%2F%2F%7B%7B.url%7D%7D";
                type = "json";
                method = "POST";
                headers = {
                  Authorization = ''Bearer ${config.sops.placeholder."ntfy/tokens/homeserver"}'';
                };
              };
            }
          ]);
          path = "/etc/podman/${name}/webhooks.json";
          owner = config.profile.user.name;
        };
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
      chown -R ${uid}:${gid} ${volume} /etc/podman/${name}
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
        "/etc/podman/${name}:/config"
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
