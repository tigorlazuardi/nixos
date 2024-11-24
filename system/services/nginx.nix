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
        pkgs.nginxModules.pam
      ];
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;
      recommendedBrotliSettings = true;
      enableReload = true;
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
      # Enable ACME implies security.acme.certs."tigor.web.id" to be created.
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = "/etc/nginx/static/tigor.web.id";
        tryFiles = "$uri $uri/ $uri.html =404";
      };
    };

    sops.secrets."nginx/htpasswd" = {
      sopsFile = ../../secrets/nginx.yaml;
      owner = "nginx";
    };

    # Enable Real IP from Cloudflare
    services.nginx.commonHttpConfig =
      # let
      #   realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
      #   fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
      #   cfipv4 = fileToList (
      #     pkgs.fetchurl {
      #       url = "https://www.cloudflare.com/ips-v4";
      #       sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
      #     }
      #   );
      #   cfipv6 = fileToList (
      #     pkgs.fetchurl {
      #       url = "https://www.cloudflare.com/ips-v6";
      #       sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
      #     }
      #   );
      # in
      #nginx
      ''
        geo $auth_ip {
            default "Password required";
            10.0.0.0/8 off;
            172.16.0.0/12 off;
            192.168.0.0/16 off;
        }

        auth_basic_user_file ${config.sops.secrets."nginx/htpasswd".path};
      '';

    # This is needed for nginx to be able to read other processes
    # directories in `/run`. Else it will fail with (13: Permission denied)
    systemd.services.nginx.serviceConfig.ProtectHome = false;
  };
}
