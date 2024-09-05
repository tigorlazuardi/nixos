{ config, pkgs, lib, ... }:
let
  cfg = config.profile.services.ntfy-sh;
  inherit (lib) mkIf;
  domain = "ntfy.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${config.services.ntfy-sh.settings.listen-http}
    '';
    environment.systemPackages = with pkgs; [
      # Access to `ntfy` cli tool
      ntfy-sh
    ];

    environment.sessionVariables = {
      NTFY_CONFIG = "/etc/ntfy/client.yml";
    };

    sops = {
      secrets =
        let
          opts = { sopsFile = ../../secrets/ntfy.yaml; };
        in
        {
          "ntfy/default/user" = opts;
          "ntfy/default/password" = opts;
        };

      templates =
        let filename = "ntfy-client.yaml"; in
        {
          ${filename} = {
            content = builtins.readFile ((pkgs.formats.yaml { }).generate filename {
              default-host = "https://${domain}";
              default-user = config.sops.placeholder."ntfy/default/user";
              default-password = config.sops.placeholder."ntfy/default/password";
            });
            path = "/etc/ntfy/client.yml";
            owner = config.profile.user.name;
          };
        };
    };

    services.ntfy-sh = {
      enable = true;
      settings =
        let
          base-dir = "/var/lib/ntfy-sh";
        in
        rec {
          listen-http = "0.0.0.0:15150";
          behind-proxy = true;
          base-url = "https://${domain}";

          # Performance. Cache and Batching.
          cache-file = "${base-dir}/cache.db";
          cache-duration = "24h";
          cache-batch-size = 10;
          cache-batch-timeout = "1s";

          # Auth
          auth-file = "${base-dir}/auth.db";
          auth-default-access = "deny-all";

          # Attachments
          attachment-cache-dir = "${base-dir}/attachments";
          attachment-expiry-duration = cache-duration;
        };
    };
  };
}
