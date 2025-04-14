{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.github-runner;
  inherit (lib) mkIf;
  repos = {
    zmk-builder = "https://github.com/tigorlazuardi/zmk-config-nicenanov2";
  };
in
{
  config = mkIf cfg.enable {
    sops.secrets."github/runners/homeserver/token".sopsFile = ../../secrets/github.yaml;
    services.github-runners = lib.attrsets.mapAttrs (name: url: {
      enable = true;
      tokenFile = config.sops.secrets."github/runners/homeserver/token".path;
      inherit url;
    }) repos;
  };
}
