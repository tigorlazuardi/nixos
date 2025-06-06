{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.wireguard;
  externalInterface = config.profile.networking.externalInterface;
  devices = [
    {
      name = "phone";
      ip = "10.100.0.2";
      secret = "wireguard/private_keys/phone";
      publicKey = "27GSz9iWqtg23sWcwIQI3VglNtE/RWykv+nZUrmHHxA=";
    }
    {
      name = "laptop";
      ip = "10.100.0.3";
      secret = "wireguard/private_keys/laptop";
      publicKey = "5nporvzbJtTQC9Hek8JBJNIF+wGlWUj4En2w9DrvaV0=";
    }
    {
      name = "oppo-find-x8";
      ip = "10.100.0.4";
      secret = "wireguard/private_keys/oppo-find-x8";
      publicKey = "ExGQMlmSVKpP3lpZKcnuAiOUOeSD44RMKf2k016rqHs=";
    }
  ];
  serverPublicKey = "GDRUvnKUPNzwAloQ5fxvdHoVw4D1YbdCR0GyiOyyB38=";
  sopsFile = ../../secrets/wireguard.yaml;
  domain = "vpn.tigor.web.id";
  inherit (lib) mkIf mergeAttrsList generators;
in
{
  config = mkIf cfg.enable {
    sops.secrets = mergeAttrsList (
      [
        {
          "wireguard/private_keys/server" = {
            inherit sopsFile;
          };
        }
      ]
      ++ (map (device: {
        ${device.secret} = {
          inherit sopsFile;
        };
      }) devices)
    );

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    sops.templates =
      let
        template =
          { privateKey, ip }:
          (generators.toINI { }) {
            Interface = {
              Address = "${ip}/32";
              PrivateKey = privateKey;
              DNS = "192.168.100.5";
            };

            Peer = {
              PublicKey = serverPublicKey;
              Endpoint = "vpn.tigor.web.id:51820";
              AllowedIPs = "0.0.0.0/0, ::/0";
            };
          };
      in
      mergeAttrsList (
        map (device: {
          "wireguard/clients/${device.name}" = {
            content = template {
              privateKey = config.sops.placeholder.${device.secret};
              ip = device.ip;
            };
            owner = config.profile.user.name;
          };
        }) devices
      );

    system.activationScripts."copy-wireguard-config-to-syncthing".text = # sh
      lib.strings.concatStringsSep "\n" (
        map (
          device:
          let
            origin = config.sops.templates."wireguard/clients/${device.name}".path;
            target = "/nas/Syncthing/Sync/WireGuard/${device.name}.conf";
          in
          #sh
          ''
            cp ${origin} ${target} || true
            chown ${config.profile.user.name}:${config.profile.user.name} ${target} || true
            chmod 0600 ${target} || true
          ''
        ) devices
      );

    networking = {
      nat = {
        enable = true;
        inherit externalInterface;
        internalInterfaces = [ "wg0" ];
      };
      firewall.allowedUDPPorts = [ 51820 ];

      wireguard.interfaces = {
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ "10.100.0.1/16" ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          privateKeyFile = config.sops.secrets."wireguard/private_keys/server".path;

          peers = map (device: {
            publicKey = device.publicKey;
            allowedIPs = [ device.ip ];
          }) devices;
        };
      };
    };
  };
}
