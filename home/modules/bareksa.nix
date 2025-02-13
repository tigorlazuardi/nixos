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

  home.file.".config/containers/containers.conf".source =
    (pkgs.formats.toml { }).generate "containers.conf"
      {
        containers = {
          netns = "host";
        };
      };
}
