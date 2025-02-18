{
  unstable,
  config,
  ...
}:
{
  sops.secrets."ai/aider" = {
    sopsFile = ../../secrets/ai.yaml;
    path = "${config.home.homeDirectory}/.aider.conf.yml";
  };
  home.packages = with unstable; [ aider-chat ];
}
