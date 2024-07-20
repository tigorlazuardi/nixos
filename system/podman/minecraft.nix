{ config, lib, ... }:
let
  name = "minecraft";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.200.1";
  image = "docker.io/05jchambers/legendary-minecraft-purpur-geyser:latest";
  rootVolume = "/nas/podman/minecraft";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
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
                <p>
                  For security reasons, connecting to the server requires Wireguard to be connected.
                  Ensure they are on first otherwise you won't be able to connect.
                </p>
                <p>
                  The server supports both Java and Bedrock Edition. Both shares the same world and can
                  play together. They only need to connect to different ports depending on the edition.
                </p>
                <p>Minecraft Java Server: <b>${domain}:25565</b></p>
                <p>Minecraft Bedrock Server: <b>${domain}:19132</b></p>
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
        TZ = "Asia/Jakarta";
      };
      ports = [
        # Java Edition Ports
        "25565:25565/udp"
        "25565:25565"
        # Bedrock Edition Ports
        "19132:19132/udp"
        "19132:19132"
      ];
      volumes = [
        "${rootVolume}:/minecraft"
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
