{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.nginx;
  inherit (lib) mkIf;
  domain = "tigor.web.id";
in
{
  config = mkIf cfg.enable {
    profile.services.authelia.enable = true;
    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;
      additionalModules = with pkgs.nginxModules; [
        fancyindex
        echo
      ];
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;
      recommendedBrotliSettings = true;
    };

    sops.secrets."nginx/htpasswd" = {
      sopsFile = ../../secrets/nginx.yaml;
      owner = "nginx";
    };

    users.users.nginx.extraGroups = [
      "acme"
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "tigor.hutasuhut@gmail.com";
    };

    # Disable ACME re-triggers every time the configuration changes
    systemd.services.nginx.unitConfig = {
      Before = lib.mkForce [ ];
      After = lib.mkForce [ "network.target" ];
      Wants = lib.mkForce [ ];
    };

    systemd.timers."acme-${domain}".timerConfig.OnCalendar = lib.mkForce "*-*-1,15 04:00:00";

    security.acme.certs."${domain}" = {
      webroot = "/var/lib/acme/acme-challenge";
      group = "nginx";
    };

    services.nginx.appendHttpConfig =
      # Catch all server. Return 444 for all requests (end connection without response)
      #nginx
      ''
        server {
            listen 80 default_server;
            server_name _;
            return 444;
        }
        server {
            listen 443 ssl default_server;     
            server_name _;
            ssl_reject_handshake on; # Reject SSL connection 
            return 444;
        }
      '';

    # Enable Real IP from Cloudflare
    services.nginx.commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v4";
            sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
          }
        );
        cfipv6 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v6";
            sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
          }
        );
      in
      # nginx
      ''
        geo $auth_ip {
            default "Password required";
            10.0.0.0/8 off;
            172.16.0.0/12 off;
            192.168.0.0/16 off;
        }

        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;

        auth_basic_user_file ${config.sops.secrets."nginx/htpasswd".path};

        log_format json_combined escape=json '{'
            '"time_local":"$time_local",'
            '"body_bytes_sent":"$body_bytes_sent",'
            '"bytes_sent": "$bytes_sent",'
            '"host":"$host",'
            '"http_referer":"$http_referer",'
            '"http_user_agent":"$http_user_agent",'
            '"http_x_forwarded_for":"$http_x_forwarded_for",'
            '"remote_addr":"$remote_addr",'
            '"remote_user":"$remote_user",'
            '"request":"$request",'
            '"request_time":"$request_time",'
            '"server_name":"$server_name",'
            '"server_protocol":"$server_protocol",'
            '"ssl_protocol": "$ssl_protocol",'
            '"ssl_cipher": "$ssl_cipher",'
            '"status":$status,'
            '"upstream_addr":"$upstream_addr",'
            '"upstream_response_time":"$upstream_response_time",'
            '"upstream_status":"$upstream_status"'
        '}';
        access_log /var/log/nginx/access.log json_combined;
      '';

    # This is needed for nginx to be able to read other processes
    # directories in `/run`. Else it will fail with (13: Permission denied)
    systemd.services.nginx.serviceConfig.ProtectHome = false;

    environment.etc."alloy/config.alloy".text =
      # hocon
      ''
          local.file_match "nginx_access_log" {
              path_targets = [{"__path__" = "/var/log/nginx/access.log"}]
              sync_period = "5s"
          }

          loki.source.file "nginx_access_log" {
            targets = local.file_match.nginx_access_log.targets
            forward_to = [loki.process.nginx_access_log.receiver]
          }

          loki.process "nginx_access_log" {
              forward_to = [loki.write.default.receiver]

              stage.json {
                  expressions = {
                    time = "time_local",
                    host = "",
                    status = "",
                    server_name = "",
                    upstream_addr = "",
                  }
              }

              stage.labels {
                  values = {
                    host = "",
                    status = "",
                    server_name = "",
                    upstream_addr = "",
                  }
              }

              stage.timestamp {
                  source = "time"
                  format = "_2/Jan/2006:15:04:05 -0700"
              }

              stage.static_labels {
                  values = {
                    source = "nginx_access_log",
                    job = "nginx",
                  }
              }
        }
      '';

  };
}
