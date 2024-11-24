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
  volume = "/nas/mediaserver/${name}";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  webhook = builtins.readFile (
    (pkgs.formats.json { }).generate "webhooks.json" [
      {
        name = "NTFY Webhook Added";
        on = [ "added" ];
        request = {
          url = "https://ntfy.tigor.web.id/ytptube?click=https%3A%2F%2F${domain}&tpl=1&t=%7B%7B.title%7D%7D&m=%5B%7B%7B%20.folder%20%7D%7D%5D%20Download%20added.";
          type = "json";
          method = "POST";
          headers = {
            Authorization = ''Bearer ${config.sops.placeholder."ntfy/tokens/homeserver"}'';
            X-Tags = "rocket";
          };
        };
      }
      {
        name = "NTFY Webhook Completed";
        on = [ "completed" ];
        request = {
          url = "https://ntfy.tigor.web.id/ytptube?click=https%3A%2F%2F${domain}&tpl=1&t=%7B%7B.title%7D%7D&m=%5B%7B%7B%20.folder%20%7D%7D%5D%20Download%20%7B%7B%20.status%20%7D%7D";
          type = "json";
          method = "POST";
          headers = {
            Authorization = ''Bearer ${config.sops.placeholder."ntfy/tokens/homeserver"}'';
            X-Tags = "heavy_check_mark";
            X-Priority = "4";
          };
        };
      }
      {
        name = "NTFY Webhook Error";
        on = [ "error" ];
        request = {
          url = "https://ntfy.tigor.web.id/ytptube?click=https%3A%2F%2F${domain}&tpl=1&t=%7B%7B.title%7D%7D&m=%5B%7B%7B%20.folder%20%7D%7D%5D%20Download%20%7B%7B%20.status%20%7D%7D";
          type = "json";
          method = "POST";
          headers = {
            Authorization = ''Bearer ${config.sops.placeholder."ntfy/tokens/homeserver"}'';
            X-Priority = "4";
            X-Tags = "x";
          };
        };
      }
    ]
  );
in
lib.mkMerge [
  (mkIf podman.${name}.enable {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:8081";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [
      domain
    ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}
      chown -R ${uid}:${gid} ${volume} /etc/podman/${name}
    '';

    systemd.services."podman-${name}".restartTriggers = [ webhook ];

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

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
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
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  })
  {
    profile.services.ntfy-sh.client.settings.subscribe =
      let
        vueIcon = pkgs.fetchurl {
          url = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Vue.js_Logo_2.svg/120px-Vue.js_Logo_2.svg.png";
          hash = "sha256-chQ5dFB22qfGpGnYJ9B6NsUWlbfAeIIoJL5bSyz2YEg=";
        };
      in
      [
        {
          command = ''${pkgs.libnotify}/bin/notify-send --app-name="ytptube" --icon="${vueIcon}" --category=im.received --urgency=normal "$title" "$message"'';
          topic = "ytptube";
        }
      ];
  }
]
