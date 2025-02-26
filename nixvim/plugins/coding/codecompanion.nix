{ unstable, ... }:
{
  programs.nixvim = {
    plugins.codecompanion = {
      enable = true;
      package = unstable.vimPlugins.codecompanion-nvim;
      settings = {
        strategies = {
          chat.adapter = "anthropic";
          inline.adapter = "anthropic";
          agent.adapter = "anthropic";
        };
        adapters = {
          anthropic.__raw = ''
            function()
              return require("codecompanion.adapters").extend("anthropic", {
                env = {
                  api_key = ([[cmd:cat %s]]):format(os.getenv "ANTHROPIC_API_KEY_FILE");
                }
              })
            end
          '';
          gemini.__raw = ''
            function()
              return require("codecompanion.adapters").extend("gemini", {
                env = {
                  api_key = ([[cmd:cat %s]]):format(os.getenv "GEMINI_API_KEY_FILE");
                }
              })
            end
          '';
          deepseek.__raw = ''
            function()
              return require("codecompanion.adapters").extend("deepseek", {
                env = {
                  api_key = ([[cmd:cat %s]]):format(os.getenv "DEEPSEEK_API_KEY_FILE");
                }
              })
            end
          '';
        };
      };
      lazyLoad.settings.cmd = [
        "CodeCompanionActions"
        "CodeCompanionChat"
      ];
      lazyLoad.settings.keys =
        let
          map =
            key: action:
            {
              mode ? [ "n" ],
              desc ? "",
            }:
            {
              __unkeyed-1 = key;
              __unkeyed-2 = action;
              inherit mode desc;
            };
        in
        [
          (map "<localleader>c" "<cmd>CodeCompanionActions<cr>" {
            desc = "Code Companion Actions";
            mode = [
              "n"
              "v"
            ];
          })
          (map "<localleader>C" "<cmd>CodeCompanionChat Toggle<cr>" {
            desc = "Code Companion Chat";
            mode = [
              "n"
              "v"
            ];
          })
        ];
    };
  };
}
