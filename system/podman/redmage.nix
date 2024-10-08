{ config, lib, ... }:
let
  name = "redmage";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.0.2";
  image = "git.tigor.web.id/tigor/redmage:latest";
  rootVolume = "/nas/redmage";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @botForbidden header_regexp User-Agent "(?i)AdsBot-Google|Amazonbot|anthropic-ai|Applebot|Applebot-Extended|AwarioRssBot|AwarioSmartBot|Bytespider|CCBot|ChatGPT|ChatGPT-User|Claude-Web|ClaudeBot|cohere-ai|DataForSeoBot|Diffbot|FacebookBot|Google-Extended|GPTBot|ImagesiftBot|magpie-crawler|omgili|Omgilibot|peer39_crawler|PerplexityBot|YouBot"

      handle @botForbidden {
        respond /* "Access Denied" 403 {
            close
        }
      }
      reverse_proxy ${ip}:8080
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}/db
      mkdir -p ${rootVolume}/images
      chown ${uid}:${gid} ${rootVolume} ${rootVolume}/db ${rootVolume}/images
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${rootVolume}/db:/app/db"
        "${rootVolume}/images:/app/downloads"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

}
