{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.couchdb;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    sops = {
      secrets = let opts = { sopsFile = ../../secrets/couchdb.yaml; }; in {
        "couchdb/admin/username" = opts;
        "couchdb/admin/password" = opts;
      };
      templates."couchdb.ini" = {
        content = builtins.readFile ((pkgs.formats.ini { }).generate "couchdb.ini" {
          admins = {
            ${config.sops.placeholder."couchdb/admin/username"} = config.sops.placeholder."couchdb/admin/password";
          };
          chttpd = {
            require_valid_user = true;
            max_http_request_size = 4294967296;
          };
          chttpd_auth = {
            require_valid_user = true;
          };
          httpd = {
            WWW-Authenticate = ''Basic realm="couchdb"'';
            enable_cors = true;
          };
          couchdb = {
            max_document_size = 50 * 1000 * 1000;
          };
          cors = {
            credentials = true;
            origin = "*";
          };
        });
        owner = config.services.couchdb.user;
      };
    };

    services.caddy.virtualHosts."couchdb.tigor.web.id".extraConfig = ''
      @origin header Origin {args[0]}
      header @origin {
        Access-Control-Allow-Origin "{args[0]}"
        Access-Control-Allow-Methods "OPTIONS,HEAD,GET,POST,PUT,PATCH,DELETE"
      }
      @options method OPTIONS
      respond @options 204

      reverse_proxy localhost:5984
    '';

    services.couchdb = {
      enable = true;
      configFile = config.sops.templates."couchdb.ini".path;
    };
  };
}
