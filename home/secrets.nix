{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";

    secrets = {
      "docker/config" = {
        path = "${config.home.homeDirectory}/.docker/config.json";
      };
      "copilot".path = "${config.home.homeDirectory}/.config/github-copilot/hosts.json";
    };
  };
}
