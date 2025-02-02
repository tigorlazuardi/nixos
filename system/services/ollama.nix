{
  config,
  lib,
  ...
}:
let
  cfg = config.profile.services.ollama;
  domain = "ollama.local";
  inherit (lib.lists) optional;
  models = cfg.models;
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      loadModels =
        [ ]
        ++ optional (models.codeCompletion != null) models.codeCompletion
        ++ optional (models.codeInstruction != null) models.codeInstruction
        ++ optional (models.chat != null) models.chat;
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

    environment.variables.OLLAMA_CHAT_MODEL = lib.mkIf (models.chat != null) models.chat;
    environment.variables.OLLAMA_CODE_COMPLETION_MODEL = lib.mkIf (
      models.codeCompletion != null
    ) models.codeCompletion;
    environment.variables.OLLAMA_CODE_INSTRUCTION_MODEL = lib.mkIf (
      models.codeInstruction != null
    ) models.codeInstruction;

    environment.variables.OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
  };
}
