# It's a pain setting up Certificate Authority, Public Key Infrastructure, etc. for OpenVPN.
# Instead setup multiple openvpn servers with multiple ports, with each server having one client.
#
# Does not scale well, but it's good enough for personal use.
#
# TODO: Create CA, and ROOTCA, and use them to sign the keys, then store in sops-nix secrets.


{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.openvpn;
  domain = "vpn.tigor.web.id";
  portLaptop = 1194;
  portPhone = 1195;
  vpn-dev-laptop = "tun0";
  vpn-dev-phone = "tun1";
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
      internalInterfaces = [ vpn-dev-laptop vpn-dev-phone ];
    };

    networking.firewall.trustedInterfaces = [ vpn-dev-laptop vpn-dev-phone ];
    networking.firewall.allowedUDPPorts = [ portLaptop portPhone ];

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
          "openvpn/key/phone" = opts;
          "openvpn/key/laptop" = opts;
        };

      # This section creates .ovpn files for the clients in /etc/openvpn folder. These should be shared with the clients.
      templates =
        let
          template = { secretPlaceholder, port, ifConfig }: ''
            dev tun
            remote "${config.sops.placeholder."openvpn/server/ip"}"
            port ${toString port}
            ifconfig ${ifConfig}
            redirect-gateway def1

            cipher AES-256-CBC
            auth-nocache

            comp-lzo
            keepalive 10 60
            resolv-retry infinite
            nobind
            persist-key
            persist-tun
            secret [inline]

            <secret>
            ${secretPlaceholder}
            </secret>
          '';
        in
        {
          "openvpn/key/phone" = {
            content = template {
              secretPlaceholder = config.sops.placeholder."openvpn/key/phone";
              port = portPhone;
              ifConfig = "10.8.1.1 10.8.1.2";
            };
            path = "/etc/openvpn/phone.ovpn";
            owner = config.profile.user.name;
          };
          "openvpn/key/laptop" = {
            content = template {
              secretPlaceholder = config.sops.placeholder."openvpn/key/laptop";
              port = portLaptop;
              ifConfig = "10.8.2.1 10.8.2.2";
            };
            path = "/etc/openvpn/laptop.ovpn";
            owner = config.profile.user.name;
          };
        };
    };
    services.openvpn.servers =
      let
        configTemplate = { secretFile, port, dev }: ''
          dev ${dev}
          proto udp
          secret ${secretFile}
          port ${toString port}

          cipher AES-256-CBC
          auth-nocache

          comp-lzo
          keepalive 10 60
          ping-timer-rem
          persist-tun
          persist-key
        '';
      in
      {
        phone = {
          config = configTemplate { secretFile = config.sops.secrets."openvpn/key/phone".path; port = portPhone; dev = vpn-dev-phone; };
          autoStart = true;
        };
        laptop = {
          config = configTemplate { secretFile = config.sops.secrets."openvpn/key/laptop".path; port = portLaptop; dev = vpn-dev-laptop; };
          autoStart = true;
        };
      };
  };
}


