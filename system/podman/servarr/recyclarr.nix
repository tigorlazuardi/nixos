{ config, lib, pkgs, ... }:
let
  podman = config.profile.podman;
  name = "recyclarr";
  recyclarr = podman.servarr.${name};
  ip = "10.88.2.100";
  image = "ghcr.io/recyclarr/recyclarr:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/${name}";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && recyclarr.enable) {

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume} 
      chown ${uid}:${gid} ${configVolume}
    '';

    sops.secrets =
      let
        opts = { sopsFile = ../../../secrets/servarr.yaml; };
      in
      {
        "servarr/api_keys/sonarr" = opts;
        "servarr/api_keys/sonarr-anime" = opts;
        "servarr/api_keys/radarr" = opts;
      };

    sops.templates."recyclarr/recylarr.yml" = {
      owner = user.name;
      path = "${configVolume}/recyclarr.yml";
      content = builtins.readFile ((pkgs.formats.yaml { }).generate "recyclarr.yml" {
        sonarr = {
          tv = {
            base_url = "http://sonarr:8989";
            api_key = config.sops.placeholders."servarr/api_keys/sonarr";
            quality_definition.type = "series";
            release_profiles = [
              {
                trash_ids = [ ];
              }
            ];
          };
          anime = {
            base_url = "http://sonarr-anime:8989";
            api_key = config.sops.placeholders."servarr/api_keys/sonarr-anime";
            quality_definition.type = "anime";
          };
        };
      });
    };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${configVolume}:/config"
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
