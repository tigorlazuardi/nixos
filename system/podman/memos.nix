{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "memos";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.88.1";
  image = "docker.io/neosmemo/memos:stable";
  rootVolume = "/wolf/podman/memos";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {

    users = {
      groups.${name}.gid = 971;
      users = {
        ${name} = {
          uid = 976;
          isSystemUser = true;
          description = "Unprivileged Podman container user for ${name}";
          group = name;
        };
        ${user.name}.extraGroups = [
          name
        ];
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."^~ /memos.api" = {
        proxyPass = "http://unix:${config.systemd.socketActivations."podman-${name}".socketAddress}";
        proxyWebsockets = true;
      };
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.memos.settings.BIND}";
        proxyWebsockets = true;
      };
    };

    systemd.socketActivations."podman-${name}" = {
      host = ip;
      port = 5230;
    };
    system.activationScripts."podman-${name}" =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      ''
        mkdir -p ${rootVolume}
        chown -R ${uid}:${gid} ${rootVolume}
      '';

    services.anubis.instances.memos.settings.TARGET = "unix://${
      config.systemd.socketActivations."podman-${name}".socketAddress
    }";

    virtualisation.oci-containers.containers.${name} =
      let
        uid = toString config.users.users.${name}.uid;
        gid = toString config.users.groups.${name}.gid;
      in
      {
        inherit image;
        hostname = name;
        autoStart = false;
        user = "${uid}:${gid}";
        environment = {
          TZ = "Asia/Jakarta";
          # MEMOS_PUBLIC = "true";
        };
        volumes = [ "${rootVolume}:/var/opt/memos" ];
        extraOptions = [
          "--network=podman"
          "--ip=${ip}"
          "--umask=0007"
        ];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
  };
}
