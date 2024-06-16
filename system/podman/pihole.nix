{ config, lib, pkgs, ... }:
let
  name = "pihole";
  podman = config.profile.podman;
  pihole = podman.pihole;
  inherit (lib) mkIf;
  gateway = "10.1.1.1";
  subnet = "10.1.1.0/29";
  ip = "10.1.1.3";
  ip-range = "10.1.1.3/29";
  image = "pihole/pihole:latest";
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


    systemd.services.create-kavita-network = {
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "podman-pihole.service" ];
      script = ''${pkgs.podman}/bin/podman network exists ${name} || ${pkgs.podman}/bin/podman network create --gateway=${gateway} --subnet=${subnet} --ip-range=${ip-range} ${name}'';
    };

    virtualisation.oci-containers.containers.pihole = {
      inherit image;
      environment = {
        TZ = "Asia/Jakarta";
        PIHOLE_DNS_ = "192.168.100.5";
        DHCP_START = "192.168.100.20";
        DHCP_END = "192.168.100.254";
        DHCP_ROUTER = "192.168.100.1";
      };
      ports = [
        "192.168.100.4:53:53/udp"
        "67:67/udp"
      ];
      volumes = [
        "pihole-etc:/etc/pihole"
        "pihole-dnsmasq:/etc/dnsmasq.d"
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
