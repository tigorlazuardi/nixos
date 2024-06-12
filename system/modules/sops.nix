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
  };
}
