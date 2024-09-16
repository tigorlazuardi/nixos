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

    environment.etc."alloy/config.alloy".text =
      /*hcl*/ ''
      local.file_match "caddy_access_log" {
          path_targets = [
              {
                  "__path__" = "/var/log/caddy/*.log",
              },
          ]
          sync_period = "30s"
      }

      loki.source.file "caddy_access_log" {
          targets = local.file_match.caddy_access_log.targets
          forward_to = [loki.process.caddy_access_log.receiver]
      }

      loki.process "caddy_access_log" {
          forward_to = [loki.write.default.receiver]

          stage.json {
              expressions = {
                  level = "",
                  host = "request.host",
                  method = "request.method",
                  proto = "request.proto",
                  ts = "",
              }
          }

          stage.labels {
              values = {
                  level = "",
                  host = "",
                  method = "",
                  proto = "",
              }
          }

          stage.label_drop {
            values = ["service_name"]
          }

          stage.static_labels {
            values = {
                job = "caddy_access_log",
            }
          }

          stage.timestamp {
            source = "ts"
            format = "unix"
          }
      }
    '';
  };
}
