{
  config,
  lib,
  ...
}:
let
  cfg = config.profile.services.ollama;
  domain = "ollama.local";
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      loadModels = cfg.models;
    };

    services.open-webui = {
      enable = true;
      port = 33998;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      };
    };

    services.nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass =
        "http://${config.services.open-webui.host}:${toString config.services.open-webui.port}";
    };

    networking.extraHosts = ''
      127.0.0.1 ${domain}
    '';

    environment.variables.OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
  };
}
