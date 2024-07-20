{ config, lib, ... }:
let
  name = "minecraft";
  podman = config.profile.podman;
  inherit (lib) mkIf strings;
  ip = "10.88.200.1";
  # image = "docker.io/05jchambers/legendary-minecraft-purpur-geyser:latest";
  image = "docker.io/itzg/minecraft-bedrock-server:latest";
  rootVolume = "/nas/podman/minecraft/hutasuhut";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  users = [
    {
      username = "CrowFX7414";
      xuid = "2533274941938385";
    }
  ];
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = /*html*/ ''
      header Content-Type text/html
      respond <<EOF
          <!DOCTYPE html>
          <html>
              <head>
                <title>Minecraft Server</title>
              </head>
              <body>
                <h1>Congrats! The minecraft server should be up!</h1>
                <h2>
                  This server is invitation only.
                  Please contact the server owner for more info.
                </h2>
                <p>Server Address: <b>${domain}</b></p>
                <p>Server Port: <b>19132</b></p>
              </body>
          </html>
          EOF 200 
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}
      chown ${uid}:${gid} ${rootVolume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        UID = uid;
        GID = gid;
        EULA = "TRUE";
        TZ = "Asia/Jakarta";
        SERVER_NAME = "Hutasuhut";
        DEFAULT_PLAYER_PERMISSION_LEVEL = "operator";
        LEVEL_NAME = "Hutasuhut";
        MAX_THREADS = "0"; # Use as many as possible
        ALLOW_LIST_USERS = strings.concatStringsSep "," (
          map (user: "${user.username}:${user.xuid}") users
        );
      };
      ports = [
        # Java Edition Ports
        # "25565:25565/udp"
        # "25565:25565"
        # Bedrock Edition Ports
        "19132:19132/udp"
        "19132:19132"
      ];
      volumes = [
        "${rootVolume}:/data"
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
