# Guide on how to create client ovpn files, and server config: https://wiki.archlinux.org/title/OpenVPN/Checklist_guide

{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.openvpn;
  domain = "vpn.tigor.web.id";
  port = 1194;
  vpn-dev = "tun0";
  externalInterface = config.profile.networking.externalInterface;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openvpn ]; # To generate keys with openvpn --genkey --secret <name>.key

    # Enable IP forwarding to allow the VPN to act as a gateway.
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [ vpn-dev ];
    };

    networking.firewall.trustedInterfaces = [ vpn-dev ];
    networking.firewall.allowedUDPPorts = [ port ];

    sops = {
      # Activate the secrets.
      secrets =
        let
          opts = {
            sopsFile = ../../secrets/openvpn.yaml;
          };
        in
        {
          "openvpn/server/ip" = opts;
          "openvpn/server/ca" = opts;
          "openvpn/server/cert" = opts;
          "openvpn/server/key" = opts;
          "openvpn/server/tls-auth" = opts;
          "openvpn/server/dh" = opts;
          "openvpn/clients/phone" = opts;
          "openvpn/clients/laptop" = opts;
        };

      # This section creates .ovpn files for the clients in /etc/openvpn folder. These should be shared with the clients.
      templates =
        let
          # secretPlaceholder is a generated inline file from easyrsa build-client-full.
          # it contains <cert>, <key>, <ca> sections.
          template = { secretPlaceholder, ifConfig }: ''
            client

            dev tun
            remote "${domain}"
            port ${toString port}
            redirect-gateway def1

            cipher AES-256-CBC
            auth-nocache

            keepalive 10 60
            resolv-retry infinite
            nobind
            persist-key
            persist-tun
            key-direction 1

            tls-client
            <tls-auth>
            ${config.sops.placeholder."openvpn/server/tls-auth"}
            </tls-auth>

            ${secretPlaceholder}
          '';
        in
        {
          "openvpn/key/phone" = {
            content = template {
              secretPlaceholder = config.sops.placeholder."openvpn/clients/phone";
              ifConfig = "10.8.1.1 10.8.1.2";
            };
            path = "/etc/openvpn/phone.ovpn";
            owner = config.profile.user.name;
          };
          "openvpn/key/laptop" = {
            content = template {
              secretPlaceholder = config.sops.placeholder."openvpn/clients/laptop";
              ifConfig = "10.8.2.1 10.8.2.2";
            };
            path = "/etc/openvpn/laptop.ovpn";
            owner = config.profile.user.name;
          };
        };
    };
    services.openvpn.servers.homeserver = {
      config = ''
        dev ${vpn-dev}
        proto udp

        tls-server
        cipher AES-256-CBC
        tls-cipher TLS-DHE-RSA-WITH-AES-256-CBC-SHA

        server 10.10.10.0 255.255.255.0

        allow-compression no
        ca ${config.sops.secrets."openvpn/server/ca".path}
        cert ${config.sops.secrets."openvpn/server/cert".path}
        key ${config.sops.secrets."openvpn/server/key".path}
        dh ${config.sops.secrets."openvpn/server/dh".path}
        tls-auth ${config.sops.secrets."openvpn/server/tls-auth".path} 0

        keepalive 10 60
        ping-timer-rem
        persist-tun
        persist-key
      '';
      autoStart = true;
    };
  };
}


