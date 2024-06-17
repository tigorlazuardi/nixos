{ config, lib, pkgs, ... }:
let
  name = "pihole";
  podman = config.profile.podman;
  pihole = podman.pihole;
  inherit (lib) mkIf lists;
  gateway = "10.1.1.1";
  subnet = "10.1.1.0/30";
  ip = "10.1.1.2";
  ip-range = "10.1.1.2/30";
  image = "pihole/pihole:latest";
  piholeDNSIPBind = "192.168.100.3";
in
{
  config = mkIf (podman.enable && pihole.enable) {
    services.caddy.virtualHosts."pihole.tigor.web.id".extraConfig = ''
      @root path /
      redir @root /admin
      reverse_proxy ${ip}:80
    '';

    sops.secrets."pihole/env" = {
      sopsFile = ../../secrets/pihole.yaml;
    };

    networking.nameservers = [ piholeDNSIPBind ];


    systemd.services."create-${name}-network" = {
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "podman-${name}.service" ];
      script = ''${pkgs.podman}/bin/podman network exists ${name} || ${pkgs.podman}/bin/podman network create --gateway=${gateway} --subnet=${subnet} --ip-range=${ip-range} ${name}'';
    };

    # We have refresh the custom.list dns list when caddy virtual hosts changes,
    # the easiest way to do so is to restart the pihole container
    systemd.services."podman-${name}".partOf = lists.optional (config.services.caddy.enable) "caddy.service";
    environment.etc."pihole/custom.list" = {
      # Copy file instead of symlink
      mode = "0444";

      # Creates a pihole custom.list file with the following pattern:
      #
      # custom.list:
      # 192.168.100.5 {domain_name_1}
      # 192.168.100.5 {domain_name_2}
      #
      # For each domain defined in services.caddy.virtualHosts
      text =
        let
          inherit (lib) strings attrsets;
        in
        ''${strings.concatStringsSep "\n" (
          attrsets.mapAttrsToList (name: _: "192.168.100.5 ${strings.removePrefix "https://" name}") config.services.caddy.virtualHosts
        )}
        '';
    };
    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      environment = {
        TZ = "Asia/Jakarta";
        PIHOLE_DNS_ = "192.168.100.5";
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
      ];
      volumes = [
        "pihole-etc:/etc/pihole"
        "pihole-dnsmasq:/etc/dnsmasq.d"
        "/etc/pihole/custom.list:/etc/pihole/custom.list"
      ];
      environmentFiles = [
        config.sops.secrets."pihole/env".path
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=${name}"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_BIND_SERVICE"
        "--cap-add=NET_RAW"
        "--cap-add=SYS_NICE"
        "--cap-add=CHOWN"
      ];
    };
  };
}
