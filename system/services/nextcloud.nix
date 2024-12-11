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
    # Instead uses bind mount and fstab to mount seeked directory to /var/lib/nextcloud.
    fileSystems."/nas/services/nextcloud" = {
      device = "/var/lib/nextcloud/data";
      fsType = "none";
      options = [ "bind" ];
    };
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      https = true;
      hostName = domain;
      config =
        let
          secrets = config.sops.secrets;
        in
        {
          adminuser = "homeserver";
          adminpassFile = secrets."nextcloud/homeserver".path;
        };
      configureRedis = true;
      extraApps = {
        inherit (pkgs.nextcloud30Packages.apps)
          memories
          calendar
          contacts
          notes
          ;
      };
      extraOptions = {
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
      };
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

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    systemd.services."nextcloud".serviceConfig = {
      CPUWeight = 10;
      CPUQuota = "25%";
      IOWeight = 10;
    };
  };
}
