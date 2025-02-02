{
  config,
  ...
}:
let
  cfg = config.profile.services.ollama;
  enable = (builtins.length cfg.models) > 0;
in
{
  services.ollama = {
    enable = enable;
  };

  services.open-webui = {
    enable = enable;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
    };
  };
}
