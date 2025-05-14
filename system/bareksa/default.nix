{ pkgs, config, ... }:
{
  imports = [
    ./kafka-ui.nix
    # ./mongo.nix
    ./nginx.nix
  ];

  sops.secrets."bareksa/openvpn".sopsFile = ../../secrets/bareksa.yaml;

  systemd.services."vpn-bareksa".serviceConfig = {
    ExecStart = "${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa/openvpn".path}";
  };
}
