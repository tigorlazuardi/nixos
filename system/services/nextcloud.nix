{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.nextcloud;
  domain = "nextcloud.tigor.web.id";
in
{
  config = lib.mkIf cfg.enable {
    users.groups.nextcloud.members = [ config.profile.user.name ];
    environment.systemPackages = with pkgs; [
      exiftool
      perl
    ];
    sops.secrets =
      let
        opts = {
          owner = "nextcloud";
          sopsFile = ../../secrets/nextcloud.yaml;
        };
      in
      {
        "nextcloud/homeserver" = opts;
      };

    # Do not set services.nextcloud.home. Issues with sandboxing nature of NixOS.
    # Instead force change the datadirectory with lib.mkForce to change where the data like images
    # will be stored.
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      https = true;
      hostName = domain;
      config =
        let
          secrets = config.sops.secrets;
        in
        {
          adminuser = "homeserver";
          adminpassFile = secrets."nextcloud/homeserver".path;
          dbtype = "pgsql";
        };
      configureRedis = true;
      caching.redis = true;
      database.createLocally = true;
      extraApps = {
        inherit (pkgs.nextcloud30Packages.apps)
          memories
          calendar
          contacts
          notes
          previewgenerator
          ;
      };
      settings = {
        datadirectory = lib.mkForce "/nas/services/nextcloud/data";
        enable_previews = true;
        default_timezone = "Asia/Jakarta";
        "memcache.local" = "\\OC\\Memcache\\Redis";
        "auth.bruteforce.protection.enabled" = true;
        enabledPreviewProviders = [
          ''OC\Preview\BMP''
          ''OC\Preview\GIF''
          ''OC\Preview\JPEG''
          ''OC\Preview\Krita''
          ''OC\Preview\MarkDown''
          ''OC\Preview\MP3''
          ''OC\Preview\Movie''
          ''OC\Preview\MP4''
          ''OC\Preview\OpenDocument''
          ''OC\Preview\PNG''
          ''OC\Preview\TXT''
          ''OC\Preview\XBitmap''
          ''OC\Preview\HEIC''
        ];
        preview_ffmpeg_path = "${pkgs.ffmpeg}/bin/ffmpeg";
        preview_imaginary_url = "http://${config.services.imaginary.address}:${toString config.services.imaginary.port}";
        "memories.exiftool_no_local" = true;
        "memories.exiftool" = "";
        "memories.vod.ffmpeg" = "${pkgs.ffmpeg}/bin/ffmpeg";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg}/bin/ffprobe";
        # "memories.vod.ffmpeg" = "";
        # "memories.vod.ffprobe" = "";
        "memories.vod.external" = false;
        preview_max_x = 1024;
        preview_max_y = 1024;
        trusted_proxies = [
          "192.168.100.0/24"
        ];
      };
    };

    systemd.services.phpfpm-nextcloud = {
      serviceConfig = {
        # Allow go-vod transcoder to be able to use GPU.
        PrivateDevices = lib.mkForce false;
      };
      path = [
        pkgs.perl
        pkgs.exiftool
      ];
    };

    systemd.services.nextcloud-cron = {
      path = [
        pkgs.perl
        pkgs.exiftool
      ];
    };

    # Nextcloud when enabled will configure nginx for given domain.
    #
    # see: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/web-apps/nextcloud.nix#L1133
    #
    # We only need to enable SSL.
    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = "tigor.web.id";
    };

  };
}
