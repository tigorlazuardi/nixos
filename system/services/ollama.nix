{
  config,
  lib,
  ...
}:
let
  cfg = config.profile.services.ollama;
  enable = (builtins.length cfg.models) > 0;
in
{
  config = lib.mkIf enable {
    services.ollama = {
      enable = enable;
    };

    services.open-webui = {
      enable = enable;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      };
    };

    environment.variables.OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
  };
}
