{ config, lib, ... }:
let
  ip = "10.88.222.222";
in
{
  virtualisation.oci-containers.containers."metrics" = {
    image = "quay.io/navidys/prometheus-podman-exporter";
    hostname = "metrics";
    autoStart = true;
    user = "0:0";
    environment = {
      TZ = "Asia/Jakarta";
      CONTAINER_HOST = "unix:///run/podman/podman.sock";
    };
    volumes = [
      "/run/podman/podman.sock:/run/podman/podman.sock"
    ];
    extraOptions = [
      "--network=podman"
      "--ip=${ip}"
      "--security-opt=label=disable"
    ];
    labels = {
      "io.containers.autoupdate" = "registry";
    };


  };
  environment.etc."alloy/config.alloy".text = lib.mkIf config.services.alloy.enable /*hcl*/ ''
    prometheus.scrape "podman" {
      targets = [{__address__ = "${ip}:9882"}]

      job_name = "podman"

      forward_to = [prometheus.remote_write.mimir.receiver]
    }
  '';
}
