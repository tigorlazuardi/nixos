{ config, lib, ... }:
let
  name = "pihole";
  podman = config.profile.podman;
  pihole = podman.pihole;
  inherit (lib) mkIf attrsets;
  ip = "10.88.1.1";
  image = "docker.io/pihole/pihole:latest";
  piholeDNSIPBind = "192.168.100.5";
  domain = "${name}.tigor.web.id";
in
{
  config = mkIf (podman.enable && pihole.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "= /" = {
          return = "301 /admin";
        };
        "/" = {
          proxyPass = "http://${ip}:80";
        };
      };
    };

    sops.secrets."pihole/env" = {
      sopsFile = ../../secrets/pihole.yaml;
    };

    networking.nameservers = [ piholeDNSIPBind ];

    # We have refresh the custom.list dns list when caddy virtual hosts changes,
    # the easiest way to do so is to restart the pihole container.
    #
    # This works by collecting all the virtual hosts defined in caddy
    # and check if the length of the list changes, if it does, we restart the pihole container.
    systemd.services."podman-${name}".restartTriggers = attrsets.mapAttrsToList (
      name: _: name
    ) config.services.caddy.virtualHosts;
    environment.etc."pihole/custom.list" = {
      # Copy file instead of symlink
      mode = "0444";

      # Creates a pihole custom.list file with the following pattern:
      #
      # custom.list:
      # 192.168.100.5 {domain_name_1}
      # 192.168.100.5 {domain_name_2}
      #
      # For each domain defined in services.nginx.virtualHosts
      text =
        let
          inherit (lib) strings attrsets;
        in
        ''
          192.168.100.5 vpn.tigor.web.id
          ${strings.concatStringsSep "\n" (
            attrsets.mapAttrsToList (
              name: _: "192.168.100.5 ${strings.removePrefix "https://" name}"
            ) config.services.nginx.virtualHosts
          )}
        '';
    };
    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      environment = {
        TZ = "Asia/Jakarta";
        PIHOLE_DNS_ = "192.168.100.3";
        DHCP_ACTIVE = "true";
        DHCP_START = "192.168.100.20";
        DHCP_END = "192.168.100.254";
        DHCP_ROUTER = "192.168.100.1";
        DNS_BOGUS_PRIV = "false";
        DNS_FQDN_REQUIRED = "false";
      };
      ports = [
        "${piholeDNSIPBind}:53:53/udp"
        "67:67/udp"
        "2000:80/tcp"
      ];
      volumes = [
        "pihole-etc:/etc/pihole"
        "pihole-dnsmasq:/etc/dnsmasq.d"
        "/etc/pihole/custom.list:/etc/pihole/custom.list"
      ];
      environmentFiles = [ config.sops.secrets."pihole/env".path ];
      extraOptions = [
        "--ip=${ip}"
        "--network=podman"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_BIND_SERVICE"
        "--cap-add=NET_RAW"
        "--cap-add=SYS_NICE"
        "--cap-add=CHOWN"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
