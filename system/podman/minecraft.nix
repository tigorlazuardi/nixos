{ config, lib, pkgs, ... }:
let
  name = "minecraft";
  podman = config.profile.podman;
  inherit (lib) mkIf strings;
  ip = "10.88.200.1";
  image = "docker.io/05jchambers/legendary-minecraft-purpur-geyser:latest";
  # image = "docker.io/itzg/minecraft-bedrock-server:latest";
  rootVolume = "/nas/podman/minecraft/hutasuhut-geyser";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  users = [
    {
      username = "CrowFX7414";
      xuid = "2533274941938385";
    }
    {
      username = "cherlyxroblox";
      xuid = "2535436320975546";
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
                <p>Bedrock Server Port: <b>19132</b></p>
                <p>Java Server Port: <b>25565</b></p>
              </body>
          </html>
          EOF 200 
    '';

    systemd =
      let serviceName = "podman-${name}"; in
      {
        tmpfiles.settings."${serviceName}-mount".${rootVolume}.d = {
          group = config.profile.user.name;
          mode = "0755";
          user = config.profile.user.name;
        };

        services."${serviceName}-autorestart" = {
          description = "Podman container ${name} autorestart";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.podman}/bin/podman restart podman-${name}";
          };
        };

        timers."${serviceName}-autorestart" = {
          description = "Podman container ${name} autorestart";
          timerConfig = {
            OnCalendar = "*-*-* 04:00:00";
          };
          wantedBy = [ "timers.target" ];
        };
      };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
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
