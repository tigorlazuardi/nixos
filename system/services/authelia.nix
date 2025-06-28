{
  config,
  lib,
  ...
}:
let
  domain = "tigor.web.id";
  vhostOptions =
    { config, ... }:
    {

      options = {
        enableAuthelia = lib.mkEnableOption "Enable authelia location";
        autheliaLocations = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
      config = lib.mkIf config.enableAuthelia {
        locations =
          {
            "/authelia".extraConfig =
              # nginx
              ''
                internal;
                proxy_pass http://127.0.0.1:9091/api/authz/auth-request;
                ## Headers
                ## The headers starting with X-* are required.
                proxy_set_header X-Original-Method $request_method;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header Content-Length "";
                proxy_set_header Connection "";

                ## Basic Proxy Configuration
                proxy_pass_request_body off;
                proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
                proxy_redirect http:// $scheme://;
                proxy_http_version 1.1;
                proxy_cache_bypass $cookie_session;
                proxy_no_cache $cookie_session;
                proxy_buffers 4 32k;
                client_body_buffer_size 128k;


                ## Advanced Proxy Configuration
                send_timeout 5m;
                proxy_read_timeout 240;
                proxy_send_timeout 240;
                proxy_connect_timeout 240;
              '';
          }
          // builtins.listToAttrs (
            map (loc: {
              name = loc;
              value.extraConfig =
                #nginx
                ''
                  auth_request /authelia;

                  ## Save the upstream metadata response headers from Authelia to variables.
                  auth_request_set $user $upstream_http_remote_user;
                  auth_request_set $groups $upstream_http_remote_groups;
                  auth_request_set $name $upstream_http_remote_name;
                  auth_request_set $email $upstream_http_remote_email;

                  ## Inject the metadata response headers from the variables into the request made to the backend.
                  proxy_set_header Remote-User $user;
                  proxy_set_header Remote-Groups $groups;
                  proxy_set_header Remote-Email $email;
                  proxy_set_header Remote-Name $name;
                  ## Modern Method: Set the $redirection_url to the Location header of the response to the Authz endpoint.
                  auth_request_set $redirection_url $upstream_http_location;
                  ## Modern Method: When there is a 401 response code from the authz endpoint redirect to the $redirection_url.
                  error_page 401 =302 $redirection_url;            

                  proxy_read_timeout 2h;
                  proxy_send_timeout 2h;
                '';
            }) config.autheliaLocations
          );
      };
    };
  name = "authelia-main";
in
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };
  config = lib.mkIf config.profile.services.authelia.enable {
    profile.services.mailcatcher.enable = lib.mkForce true;
    sops.secrets =
      let
        autheliaOpts = {
          sopsFile = ../../secrets/authelia.yaml;
          owner = config.services.authelia.instances.main.user;
        };
      in
      {
        "authelia/main/jwt" = autheliaOpts;
        "authelia/main/session" = autheliaOpts;
        "authelia/main/storage" = autheliaOpts;
        "authelia/main/users.yaml" = autheliaOpts;
      };
    services.nginx.virtualHosts."auth.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.${name}.settings.BIND}";
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

    users.users.nginx.extraGroups = [
      config.services.authelia.instances.main.group
    ];

    services.anubis.instances.${name}.settings.TARGET = "http://127.0.0.1:9091";

    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/main/jwt".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/main/storage".path;
        sessionSecretFile = config.sops.secrets."authelia/main/session".path;
      };
      settings = {
        theme = "light";
        log.level = "debug";
        totp = {
          issuer = "auth.${domain}";
          period = 30;
          skew = 1;
        };
        server.endpoints.authz.auth-request.implementation = "AuthRequest";
        storage.local.path = "/var/lib/authelia-main/data.db";
        authentication_backend = {
          disable_reset_password = true;
          refresh_interval = "5m";
          file = {
            path = config.sops.secrets."authelia/main/users.yaml".path;
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
        notifier = {
          disable_startup_check = true;
          smtp = {
            address =
              let
                inherit (config.services.mailcatcher.smtp) ip port;
              in
              "smtp://${ip}:${toString port}";
            # We don't need TLS since it's loopback to the mailcatcher service.
            disable_require_tls = true;
            disable_starttls = true;
            sender = "Authelia <authelia@${domain}>";
            identifier = "Authelia";
          };
          # filesystem.filename = "/var/lib/authelia-main/notification.txt";
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
              policy = "two_factor";
            }
          ];
        };
        session = {
          redis.host = config.services.redis.servers.${name}.unixSocket;
          cookies = [
            {
              inherit domain;
              authelia_url = "https://auth.${domain}";
              name = "authelia_session";
              same_site = "lax";
              inactivity = "15m";
              expiration = "24h";
              remember_me = "30d";
            }
          ];
        };
      };
    };
    systemd.services.${name} =
      let
        dependencies = [ "redis-${name}.service" ];
      in
      {
        after = dependencies;
        requires = dependencies;
      };
    services.redis.servers.${name} = {
      enable = true;
      user = config.services.authelia.instances.main.user;
    };
  };
}
