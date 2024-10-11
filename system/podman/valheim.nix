{ config, lib, pkgs, ... }:
let
  name = "valheim";
  podman = config.profile.podman;
  inherit (lib) mkIf strings;
  ip = "10.88.200.10";
  image = "docker.io/lloesche/valheim-server";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  base_dir = "/var/lib/${name}";
in
lib.mkMerge [
  (mkIf (podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:80
    '';

    sops =
      let
        opts = { sopsFile = ../../secrets/valheim.yaml; };
      in
      {
        secrets = {
          "valheim/server/password" = opts;
          "valheim/admins/admin_1" = opts;
          "valheim/admins/admin_2" = opts;
          "valheim/admins/admin_3" = opts;
        };

        templates."valheim-env".content =
          let
            placeholder = config.sops.placeholder;
          in
            /*sh*/ ''
            SERVER_PASS=${placeholder."valheim/server/password"}
            ADMINLIST_IDS=${placeholder."valheim/admins/admin_1"} ${placeholder."valheim/admins/admin_2"} ${placeholder."valheim/admins/admin_3"}
          '';
      };

    systemd.tmpfiles.settings."podman-${name}".${base_dir}.d = {
      group = config.profile.user.name;
      mode = "0755";
      user = config.profile.user.name;
    };

    virtualisation.oci-containers.containers.${name} =
      {
        inherit image;
        hostname = name;
        autoStart = true;
        ports = [
          "2456:2456/udp"
          "2457:2457/udp"
        ];
        volumes = [
          "${base_dir}/config:/config"
          "${base_dir}/data:/opt/valheim"
        ];
        environment = {
          TZ = "Asia/Jakarta";
          SERVER_NAME = "Three Musketeers";
          WORLD_NAME = "Bebas";
          STATUS_HTTP = "true";
          PUID = uid;
          PGID = gid;
        };
        extraOptions = [
          "--network=podman"
          "--ip=${ip}"
          "--cap-add=sys_nice"
        ];
        environmentFiles = [
          config.sops.templates."valheim-env".path
        ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  })
  {
    profile.services.ntfy-sh.client.settings.subscribe = [
      {
        topic = "valheim";
        command = ''${pkgs.libnotify}/bin/notify-send --category=im.received --urgency=normal "$title" "$message"'';
      }
    ];
  }
]
