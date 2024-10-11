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
      description = "ntfy client";
      after = [ "network-online.target" ];
      restartTriggers = [ (builtins.toJSON cfg.client.settings) ];
      environment = {
        DISPLAY = ":0";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString config.profile.user.uid}/bus";
      };
      path = [ pkgs.bash ];
      serviceConfig = {
        User = toString config.profile.user.uid;
        Group = toString config.profile.user.gid;
        ExecStart = "${pkgs.ntfy-sh}/bin/ntfy subscribe --config ${configPath} --from-config";
        Restart = "on-failure";
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
                detault-token = config.sops.placeholder."ntfy/tokens/tigor";
              } // cfg.client.settings
            ));
            path = configPath;
            owner = config.profile.user.name;
          };
        };
    };
  })
]
