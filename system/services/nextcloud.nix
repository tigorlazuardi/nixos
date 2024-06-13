{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.nextcloud;
in
{
  imports = [ ./nextcloud-extras.nix ];
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
    fileSystems."/nas/nextcloud" = {
      device = "/var/lib/nextcloud";
      fsType = "none";
      options = [ "bind" ];
    };
    services.nextcloud =
      let
        secrets = config.sops.secrets;
      in
      {
        enable = true;
        https = true;
        webserver = "caddy";
        hostName = "nextcloud.tigor.web.id"; # The nextcloud-extras will ensure Caddy to take care of this.
        config = {
          adminuser = "homeserver";
          adminpassFile = secrets."nextcloud/homeserver".path;
        };
      };
  };
}
