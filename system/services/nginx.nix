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
  vhostOptions =
    { config, ... }:
    {
      options = {
        enableAuthelia = lib.mkEnableOption "Enable authelia location";
      };
      config = lib.mkIf config.enableAuthelia {
        locations = {
          "/authelia".extraConfig =
            # nginx
            ''
              # Virtual endpoint created by nginx to forward auth requests.
              location /authelia {
                internal;
                set $upstream_authelia http://127.0.0.1:9091/api/verify;
                proxy_pass_request_body off;
                proxy_pass $upstream_authelia;    
                proxy_set_header Content-Length "";

                # Timeout if the real server is dead
                proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

                # [REQUIRED] Needed by Authelia to check authorizations of the resource.
                # Provide either X-Original-URL and X-Forwarded-Proto or
                # X-Forwarded-Proto, X-Forwarded-Host and X-Forwarded-Uri or both.
                # Those headers will be used by Authelia to deduce the target url of the     user.
                # Basic Proxy Config
                client_body_buffer_size 128k;
                proxy_set_header Host $host;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $remote_addr; 
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Forwarded-Uri $request_uri;
                proxy_set_header X-Forwarded-Ssl on;
                proxy_redirect  http://  $scheme://;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                proxy_cache_bypass $cookie_session;
                proxy_no_cache $cookie_session;
                proxy_buffers 4 32k;

                # Advanced Proxy Config
                send_timeout 5m;
                proxy_read_timeout 240;
                proxy_send_timeout 240;
                proxy_connect_timeout 240;
              }
            '';
        };
      };
    };
in
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };
  config = mkIf cfg.enable {
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

    services.nginx.virtualHosts."auth.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9091";
        proxyWebsockets = true;
        extraConfig =
          #nginx
          ''
            client_body_buffer_size 128k;

            #Timeout if the real server is dead
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

            # Advanced Proxy Config
            send_timeout 5m;
            proxy_read_timeout 360;
            proxy_send_timeout 360;
            proxy_connect_timeout 360;
            proxy_set_header Connection "";
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
            proxy_buffers 64 256k;
          '';
      };
    };

    sops.secrets =
      let
        autheliaOpts = {
          sopsFile = ../../secrets/authelia.yaml;
          owner = config.services.authelia.instances.nginx.user;
        };
      in
      {
        "nginx/htpasswd" = {
          sopsFile = ../../secrets/nginx.yaml;
          owner = "nginx";
        };
        "authelia/nginx/jwt" = autheliaOpts;
        "authelia/nginx/session" = autheliaOpts;
        "authelia/nginx/storage" = autheliaOpts;
        "authelia/nginx/users.yaml" = autheliaOpts;
      };

    services.authelia.instances.nginx = {
      enable = true;
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/nginx/jwt".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/nginx/storage".path;
        sessionSecretFile = config.sops.secrets."authelia/nginx/session".path;
      };
      settings = {
        theme = "light";
        default_redirection_url = "https://${domain}";
        log.level = "debug";
        totp = {
          issuer = "auth.${domain}";
          period = 30;
          skew = 1;
        };
        storage.local.path = "/var/lib/authelia-nginx/data.db";
        authentication_backend = {
          disable_reset_password = true;
          refresh_interval = "5m";
          file = {
            path = config.sops.secrets."authelia/nginx/users.yaml".path;
            password = {
              algorithm = "argon2id";
              iterations = 1;
              key_length = 32;
              salt_length = 16;
              memory = 1024;
              parallelism = 8;
            };
          };
        };
        access_control = {
          default_policy = "deny";
          rules = [
            {
              # Allow access to the authelia authentication portal.
              domain = "auth.${domain}";
              policy = "bypass";
            }
            {
              domain = "*.${domain}";
              policy = "one_factor";
            }
          ];
        };
      };
    };

    users.users.nginx.extraGroups = [
      "acme"
      config.services.authelia.instances.nginx.group
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
