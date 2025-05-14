{ pkgs, config, ... }:
let
  sopsFile = ../../secrets/bareksa.yaml;
in
{
  sops.secrets = {
    "bareksa/openvpn" = {
      inherit sopsFile;
    };
  };

  programs.zsh.shellAliases = {
    vpn-bareksa = "sudo ${pkgs.openvpn}/bin/openvpn --config ${
      config.sops.secrets."bareksa/openvpn".path
    }";
  };
  programs.fish.shellAbbrs.vpn-bareksa = "sudo ${pkgs.openvpn}/bin/openvpn --config ${
    config.sops.secrets."bareksa/openvpn".path
  }";
}
