{ unstable, ... }:
{
  programs.nixvim = {
    plugins = {
      # Copilot only initialized upon InsertEnter,
      # but it will take a few seconds to load.
      #
      # There will be error messages when copilot.lua
      # has not finishing initializing yet.
      #
      # So we just need to silence it.
      #
      # Issue: https://github.com/zbirenbaum/copilot.lua/issues/321
      noice.settings.routes = [
        {
          filter = {
            event = "msg_show";
            any = [ { find = "Agent service not initialized"; } ];
          };
          opts = {
            skip = true;
          };
        }
      ];
      copilot-lua = {
        enable = true;
        lazyLoad.settings.event = [ "InsertEnter" ];
        package = unstable.vimPlugins.copilot-lua;
        settings = {
          panel.enabled = false;
          suggestion = {
            enabled = true;
            auto_trigger = true;
            hide_during_completion = false;
            keymap.accept = "<a-l>";
          };
          filetypes."*" = true;
        };
        luaConfig.post = ''
          vim.keymap.set("i", "<c-e>", function()
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").dismiss()
            end
            return "<c-e>"
          end, {
            silent = true,
            expr = true,
          })
        '';
      };
    };
  };
}
