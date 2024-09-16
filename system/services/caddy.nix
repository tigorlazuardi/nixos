{ config, lib, ... }:
let
  cfg = config.profile.services.caddy;
  inherit (lib) mkIf attrsets strings lists;
in
{
  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };

    services.caddy.globalConfig = /*caddy*/ ''
      servers {
          metrics
      } 
    '';

    services.caddy.virtualHosts =
      let
        domains = attrsets.mapAttrsToList (name: _: strings.removePrefix "https://" name) config.services.caddy.virtualHosts;
        sortedDomains = lists.sort (a: b: a < b) domains;
        list = map
          (domain: /*html*/ ''
            <div class="col-12 col-sm-6 col-md-4 col-lg-3 text-center align-middle">
                <a href="https://${domain}">${domain}</a>
            </div>'')
          sortedDomains;
        items = strings.concatStringsSep "\n" list;
        html = /*html*/
          ''<!DOCTYPE html>
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
            </html>'';
      in
      {
        "router.tigor.web.id".extraConfig = ''
          @denied not remote_ip private_ranges 

          respond @denied "Access denied" 403

          reverse_proxy 192.168.100.1
        '';
        "tigor.web.id".extraConfig =
          ''
            header Content-Type text/html
            respond <<EOF
                ${html}
                EOF 200
          '';
        "crowfx.web.id".extraConfig =
          ''
            header Content-Type text/html
            respond <<EOF
                ${html}
                EOF 200
          '';
      };

  };
}
