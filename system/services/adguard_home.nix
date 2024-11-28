{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.adguardhome;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."adguard.tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://0.0.0.0:3000";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [
      "adguard.tigor.web.id"
    ];

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
            name = config.profile.user.name;
            # It's a huge pain in the neck integrating this with sops.
            # This is usually encrypted further with age, but for simplicity's sake, I'll just leave it as is.
            # I just have to make sure the password for this is unique to this service.
            password = "$2b$10$vD/9Xr7/TSq5kFAMNbBVvuZzhzmsxoKOpIypBL6qjZuEZwdb5kgOO";
          }
        ];
        auth_attempts = 3;
        block_auth_min = 5;
        dns = {
          bind_hosts = [
            "192.168.100.5"
          ];
          upstream_dns = [
            "tls://dns.bebasid.com:853"
            "https://dns.bebasid.com/dns-query"
            # "quic://dns-unfiltered.adguard.com"
            # "tls://dns-unfiltered.adguard.com"
            # "94.140.14.140"
          ];
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
        };
        user_rules = [
          "@@||stats.grafana.org^" # Allow Grafana to collect stats of my Grafana instance.
        ];
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
            {
              domain = "*.tigor.web.id";
              answer = "192.168.100.5";
            }
            {
              domain = "tigor.web.id";
              answer = "192.168.100.5";
            }
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
