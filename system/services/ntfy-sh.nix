{ config, pkgs, lib, ... }:
let
  cfg = config.profile.services.ntfy-sh;
  client = cfg.client;
  inherit (lib) mkIf;
  domain = "ntfy.tigor.web.id";
  listenAddress = "0.0.0.0:15150";
  configPath = "/etc/ntfy/client.yml";
in
lib.mkMerge [
  (mkIf cfg.enable {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${listenAddress}
    '';

    services.ntfy-sh = {
      enable = true;
      settings =
        let
          base-dir = "/var/lib/ntfy-sh";
        in
        rec {
          listen-http = listenAddress;
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
  })
  (mkIf client.enable {
    environment.systemPackages = with pkgs; [
      # Access to `ntfy` cli tool
      ntfy-sh
    ];

    environment.sessionVariables = {
      NTFY_CONFIG = configPath;
    };

    systemd.services.ntfy-client = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        DISPLAY = ":0";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString config.profile.user.uid}/bus";
      };
      restartTriggers = [ (builtins.toJSON cfg.client.settings) ];
      path = with pkgs; [ bash libnotify ];
      description = "ntfy-sh client";
      serviceConfig = {
        ExecStart = "${pkgs.ntfy-sh}/bin/ntfy --debug subscribe --config /etc/ntfy/client.yml --from-config";
        Restart = "on-failure";
        User = config.profile.user.uid;
        Group = config.profile.user.gid;
      };
    };

    sops = {
      secrets =
        let
          opts = { sopsFile = ../../secrets/ntfy.yaml; };
        in
        {
          "ntfy/tokens/tigor" = opts;
        };

      templates =
        let filename = "ntfy-client.yaml"; in
        {
          ${filename} = {
            content = builtins.readFile ((pkgs.formats.yaml { }).generate filename (
              {
                default-host = "https://${domain}";
                default-token = config.sops.placeholder."ntfy/tokens/tigor";
                default-command = ''${pkgs.libnotify}/bin/notify-send --category=im.received --urgency=normal "$title" "$message"'';
              } // cfg.client.settings
            ));
            path = configPath;
            owner = config.profile.user.name;
          };
        };
    };
  })
]
