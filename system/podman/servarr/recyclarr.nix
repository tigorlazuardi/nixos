{
  config,
  lib,
  pkgs,
  ...
}:
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
        opts = {
          sopsFile = ../../../secrets/servarr.yaml;
        };
      in
      {
        "servarr/api_keys/sonarr" = opts;
        "servarr/api_keys/sonarr-anime" = opts;
        "servarr/api_keys/radarr" = opts;
      };

    sops.templates."recyclarr/recylarr.yml" = {
      owner = user.name;
      path = "${configVolume}/recyclarr.yml";
      content = builtins.readFile (
        (pkgs.formats.yaml { }).generate "recyclarr.yml" {
          radarr.movies = {
            base_url = "http://radarr:7878";
            api_key = config.sops.placeholder."servarr/api_keys/radarr";
            quality_definition.type = "movie";
            delete_old_custom_formats = true;
            custom_formats = [
              {
                trash_ids = [
                  # x264 only. For 720p and 1080p releases.
                  "2899d84dc9372de3408e6d8cc18e9666"
                ];
              }
            ];
          };
          sonarr = {
            # tv = {
            #   base_url = "http://sonarr:8989";
            #   api_key = config.sops.placeholder."servarr/api_keys/sonarr";
            #   quality_definition.type = "series";
            #   custom_formats = [ ];
            # };
            anime = {
              base_url = "http://sonarr-anime:8989";
              api_key = config.sops.placeholder."servarr/api_keys/sonarr-anime";
              quality_definition.type = "anime";
              delete_old_custom_formats = true;
              custom_formats = [
                # sudo podman run --rm ghcr.io/recyclarr/recyclarr list custom-formats sonarr
                {
                  trash_ids = [
                    # Anime Web Tier 02 (Top FanSubs)
                    "19180499de5ef2b84b6ec59aae444696"
                    # Anime Web Tier 03 (Official Subs)
                    "c27f2ae6a4e82373b0f1da094e2489ad"
                    # Anime web tier 04 (Official Subs)
                    "4fd5528a3a8024e6b49f9c67053ea5f3"
                  ];
                }
              ];
            };
          };
        }
      );
    };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [ "${configVolume}:/config" ];
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
