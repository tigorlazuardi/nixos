{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.adguardhome;
  inherit (lib) mkIf;
  domain = "adguard.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://0.0.0.0:3000";
          proxyWebsockets = true;
        };
      };
    };

    sops.secrets =
      let
        opts = {
          sopsFile = ./../../secrets/adguard.yaml;
        };
      in
      {
        "adguard/root/username" = opts;
        "adguard/root/password" = opts;
      };

    # Replace secrets first before
    systemd.services.adguardhome = {
      serviceConfig = {
        LoadCredential = [
          "username:${config.sops.secrets."adguard/root/username".path}"
          "password:${config.sops.secrets."adguard/root/password".path}"
        ];
      };
      preStart =
        lib.mkAfter
          #sh
          ''
            ${pkgs.replace-secret}/bin/replace-secret '@USERNAME@' ''${CREDENTIALS_DIRECTORY}/username /var/lib/private/AdGuardHome/AdGuardHome.yaml
            ${pkgs.replace-secret}/bin/replace-secret '@PASSWORD@' ''${CREDENTIALS_DIRECTORY}/password /var/lib/private/AdGuardHome/AdGuardHome.yaml
          '';
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      settings = {
        dhcp = {
          enabled = true;
          dhcpv4 = {
            gateway_ip = "192.168.100.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.100.20";
            range_end = "192.168.100.250";
          };
        };
        http = {
          session_ttl = "24h";
        };
        users = [
          {
            # These two values will be substituted by secrets in the preStart hook of the systemd service.
            name = "@USERNAME@";
            password = "@PASSWORD@";
          }
        ];
        auth_attempts = 3;
        block_auth_min = 5;
        dns = {
          bind_hosts = [
            "192.168.100.5"
          ];
          upstream_dns = [
            # "tls://dns.bebasid.com:853"
            # "https://dns.bebasid.com/dns-query"
            "quic://unfiltered.adguard-dns.com"
          ];
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
          fallback_dns = [
            "tls://1.1.1.1"
            "tls://8.8.8.8"
          ];
        };
        user_rules =
          [
            "@@||stats.grafana.org^" # Allow Grafana to collect stats of my Grafana instance.
            "192.168.100.5 vpn.tigor.web.id"
          ]
          ++ lib.attrsets.mapAttrsToList (
            name: _: "192.168.100.5 ${lib.strings.removePrefix "https://" name}"
          ) config.services.nginx.virtualHosts;
        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
          # {
          #   enabled = true;
          #   url = "https://raw.githubusercontent.com/bebasid/bebasdns/main/dev/resources/hosts/custom-filtering-rules-blocklist";
          #   name = "BebasDNS Custom Filtering Rules";
          #   id = 3;
          # }
        ];
        filtering = {
          filtering_enabled = true;
          rewrites = [
            # {
            #   domain = "*.tigor.web.id";
            #   answer = "192.168.100.5";
            # }
            # {
            #   domain = "tigor.web.id";
            #   answer = "192.168.100.5";
            # }
            {
              domain = "gitlab.bareksa.com";
              answer = "192.168.50.217";
            }
          ];
        };
      };
    };
  };
}
