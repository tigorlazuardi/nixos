{ config, lib, pkgs, ... }:
let
  name = "minecraft";
  podman = config.profile.podman;
  inherit (lib) mkIf strings;
  ip = "10.88.200.1";
  image = "docker.io/05jchambers/legendary-minecraft-purpur-geyser:latest";
  # image = "docker.io/itzg/minecraft-bedrock-server:latest";
  rootVolume = "/nas/podman/minecraft/hutasuhut-geyser";
  # rootVolume = "/nas/podman/minecraft/hutasuhut";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  users = [
    {
      username = "CrowFX7414";
      xuid = "2533274941938385";
      floodgate-uuid = "00000000-0000-0000-0009-000009085ad1";
    }
    {
      username = "cherlyxroblox";
      xuid = "2535436320975546";
      floodgate-uuid = "00000000-0000-0000-0009-01f745432aba";
    }
  ];

  server-properties = pkgs.writeText "server.properties" /*ini*/ ''
    #Minecraft server properties
    accepts-transfers=false
    allow-flight=false
    allow-nether=true
    broadcast-console-to-ops=true
    broadcast-rcon-to-ops=true
    bug-report-link=
    debug=false
    difficulty=easy
    enable-command-block=false
    enable-jmx-monitoring=false
    enable-query=false
    enable-rcon=false
    enable-status=true
    enforce-secure-profile=false
    enforce-whitelist=false
    entity-broadcast-range-percentage=100
    force-gamemode=false
    function-permission-level=2
    gamemode=survival
    generate-structures=true
    generator-settings={}
    hardcore=false
    hide-online-players=false
    initial-disabled-packs=
    initial-enabled-packs=vanilla
    level-name=Hutasuhut
    level-seed=
    level-type=default
    log-ips=true
    max-chained-neighbor-updates=1000000
    max-players=20
    max-tick-time=120000
    max-world-size=29999984
    motd=Hutasuhut Geyser Server
    network-compression-threshold=512
    online-mode=true
    op-permission-level=4
    player-idle-timeout=0
    prevent-proxy-connections=false
    pvp=true
    query.port=25565
    rate-limit=0
    rcon.password=
    rcon.port=25575
    region-file-compression=deflate
    require-resource-pack=false
    resource-pack=
    resource-pack-id=
    resource-pack-prompt=
    resource-pack-sha1=
    server-ip=
    server-name=Unknown Server
    server-port=25565
    simulation-distance=10
    spawn-animals=true
    spawn-monsters=true
    spawn-npcs=true
    spawn-protection=0
    sync-chunk-writes=true
    text-filtering-config=
    use-native-transport=true
    view-distance=10
    white-list=false
  '';
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig =
      /*html*/
      ''
        header Content-Type text/html
        respond <<EOF
            <!DOCTYPE html>
            <html>
                <head>
                    <title>Minecraft Server</title>
                </head>
                <body>
                    <h1>Congrats! The minecraft geyser server should be up!</h1>
                    <h2>
                    This server is invitation only.
                    Please contact the server owner for more info.
                    </h2>
                    <p>Server: <b>${domain}</b></p>
                    <p>Bedrock Port: <b>19132</b></p>
                    <p>Java Port: <b>25565</b></p>
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
        # UID = uid;
        # GID = gid;
        # EULA = "TRUE";
        TZ = "Asia/Jakarta";
        # SERVER_NAME = "Hutasuhut";
        # DEFAULT_PLAYER_PERMISSION_LEVEL = "operator";
        # LEVEL_NAME = "Hutasuhut";
        # MAX_THREADS = "0"; # Use as many as possible
        # ALLOW_LIST_USERS = strings.concatStringsSep "," (
        #   map (user: "${user.username}:${user.xuid}") users
        # );
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
        "${server-properties}:/minecraft/server.properties"
        # "${rootVolume}:/data"
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
