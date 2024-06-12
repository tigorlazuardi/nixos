{ pkgs, ... }:
let
  owner = "tigor";
in
{
  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${owner}/.config/sops/age/keys.txt";

    secrets = {
      "smb/secrets" = { inherit owner; };
      "docker/config" = {
        inherit owner;
        path = "/home/${owner}/.docker/config.json";
      };
    };
  };
}
