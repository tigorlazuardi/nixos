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
      environmentVariables = {
        OLLAMA_KV_CACHE_TYPE = "f16";
      };
      loadModels = [ cfg.model ];
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

    systemd.services.ollama-model-runner = {
      unitConfig = {
        After = [
          "ollama.service"
          "ollama-model-loader.service"
        ];
        BindsTo = [ "ollama.service" ];
        Description = "Run Ollama model";
      };
      serviceConfig = {
        ExecStart = "${config.services.ollama.package}/bin/ollama run ${cfg.model}";
        ExecStop = "${config.services.ollama.package}/bin/ollama stop ${cfg.model}";
        Restart = "on-failure";
        RestartSec = "1s";
        RestartMaxDelaySec = "2h";
        RestartSteps = "10";
        Type = "simple";
        DynamicUser = true;
      };
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = "/var/lib/ollama";
        HSA_OVERRIDE_GFX_VERSION = "10.3.0";
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_MODELS = "/var/lib/ollama/models";
      };
    };

    environment.variables.OLLAMA_MODEL = cfg.model;

    environment.variables.OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
  };
}
