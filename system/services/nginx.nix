{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.nginx;
  inherit (lib)
    mkIf
    attrsets
    strings
    lists
    ;
in
{
  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      additionalModules = [
        pkgs.nginxModules.fancyindex
      ];
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;
      recommendedBrotliSettings = true;
    };

    users.users.nginx.extraGroups = [ "acme" ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "tigor.hutasuhut@gmail.com";
    };

    # Enable Basic Authentication via PAM
    security.pam.services.nginx.setEnvironment = false;
    systemd.services.nginx.serviceConfig = {
      SupplementaryGroups = [ "shadow" ];
    };

    # Disable ACME re-triggers every time the configuration changes
    systemd.services.nginx.unitConfig = {
      Before = lib.mkForce [ ];
      After = lib.mkForce [ "network.target" ];
      Wants = lib.mkForce [ ];
    };

    environment.etc."nginx/static/tigor.web.id/index.html" = {
      text =
        let
          domains = attrsets.mapAttrsToList (
            name: _: strings.removePrefix "https://" name
          ) config.services.nginx.virtualHosts;
          sortedDomains = lists.sort (a: b: a < b) domains;
          list = map (
            domain: # html
            ''
              <div class="col-12 col-sm-6 col-md-4 col-lg-3 text-center align-middle">
                  <a href="https://${domain}">${domain}</a>
              </div>
            '') sortedDomains;
          items = strings.concatStringsSep "\n" list;
        in
        # html
        ''
          <!DOCTYPE html>
          <html>
              <head>
                  <title>Hosted Sites</title>
                  <link
                    rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
                    crossorigin="anonymous">
              </head>
              <body class="container">
                  <h1 class="text-center">Hosted Sites</h1>
                  <div class="row g-4">
                      ${items}
                  </div>
              </body>
          </html>
        '';
      user = "nginx";
      group = "nginx";
    };

    services.nginx.virtualHosts."tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        root = "/etc/nginx/static/tigor.web.id";
        tryFiles = "$uri $uri/ $uri.html =404";
      };
    };

    systemd.timers."acme-tigor.web.id".timerConfig.OnCalendar = lib.mkForce "*-*-1,15 04:00:00";

    security.acme.certs."tigor.web.id" = {
      webroot = "/var/lib/acme/.challenges";
    };

    sops.secrets."nginx/htpasswd" = {
      sopsFile = ../../secrets/nginx.yaml;
      owner = "nginx";
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
            '"host":"$host",'
            '"remote_addr":"$remote_addr",'
            '"remote_user":"$remote_user",'
            '"request":"$request",'
            '"status":$status,'
            '"body_bytes_sent":"$body_bytes_sent",'
            '"http_referer":"$http_referer",'
            '"http_user_agent":"$http_user_agent",'
            '"http_x_forwarded_for":"$http_x_forwarded_for",'
            '"request_time":"$request_time",'
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
              path_targets = [
                  {
                      "__path__" = "/var/log/nginx/access.log",
                  },
              ]
              sync_period = "30s"
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
                      request = "",
                      status = "",
                  }
              }

              stage.labels {
                  values = {
                      host = "",
                      request = "",
                      status = "",
                  }
              }

              stage.static_labels {
                  values = {
                      level = "info",
                      job = "nginx_access_log",
                  }
              } 

              stage.timestamp {
                  source = "time"
                  format = "_2/Jan/2006:15:04:05 -0700"
              }
        }
      '';

  };
}
