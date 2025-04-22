{
  config,
  pkgs,
  ...
}:
{
  sops.secrets."ai/aider" = {
    sopsFile = ../../secrets/ai.yaml;
    path = "${config.home.homeDirectory}/.aider.conf.yml";
  };
  home.packages = with pkgs; [ aider-chat ];
}
