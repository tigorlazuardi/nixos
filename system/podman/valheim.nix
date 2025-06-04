{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "valheim";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.200.10";
  image = "docker.io/lloesche/valheim-server";
  domain = "${name}.tigor.web.id";
  base_dir = "/var/lib/${name}";
  valproxy = pkgs.fetchFromGitea {
    domain = "git.tigor.web.id";
    owner = "tigor";
    repo = "valproxy";
    rev = "238ea6633e1cfb62cee3738a4777000c47d5a892";
    hash = "sha256-x4Awl2WN8nefT25p61hZXc0xIyIfn0nD3HMd0G5W/gM=";
  };
in
{
  config = mkIf podman.${name}.enable {
    profile.services.ntfy-sh.client.settings.subscribe = [ { topic = "valheim"; } ];
    users = {
      users.${name} = {
        isSystemUser = true;
        group = name;
        description = "Unpriviledged system account for ${name} service";
        uid = 901;
      };
      groups.${name}.gid = 901;
    };
    system.activationScripts."podman-${name}" =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      ''
        mkdir -p ${base_dir}
        chown -R ${uid}:${gid} ${base_dir}
      '';
    sops =
      let
        opts = {
          sopsFile = ../../secrets/valheim.yaml;
        };
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
          # sh
          ''
            SERVER_PASS=${placeholder."valheim/server/password"}
            ADMINLIST_IDS=${placeholder."valheim/admins/admin_1"} ${placeholder."valheim/admins/admin_2"} ${
              placeholder."valheim/admins/admin_3"
            }
          '';
      };

    systemd.tmpfiles.settings."podman-${name}" = {
      ${base_dir}.d = {
        group = config.profile.user.name;
        mode = "0755";
        user = config.profile.user.name;
      };
    };

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    virtualisation.oci-containers.containers.${name} =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      {
        inherit image;
        hostname = name;
        autoStart = false;
        # ports = [ "2456:2456/udp" ];
        volumes = [
          "${base_dir}/config:/config"
          "${base_dir}/data:/opt/valheim"
        ];
        user = "${uid}:${gid}";
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
          "--stop-signal=SIGINT"
          "--stop-timeout=30"
        ];
        environmentFiles = [ config.sops.templates."valheim-env".path ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
    systemd.sockets."podman-${name}-proxy" = {
      listenDatagrams = [ "0.0.0.0:2456" ];
      wantedBy = [ "sockets.target" ];
    };
    systemd.services."podman-${name}-proxy" = {
      unitConfig = {
        Requires = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
        After = [
          "podman-${name}.service"
          "podman-${name}-proxy.socket"
        ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.nodejs_latest}/bin/node ${valproxy}/index.js ${ip} 2546";
      };
    };
  };
}
