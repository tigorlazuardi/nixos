{ unstable, ... }:
{
  programs.nixvim = {
    plugins = {
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
            keymap.accept = false;
            keymap.dismiss = "<c-e>";
          };
          filetypes."*" = true;
        };
        luaConfig.post = ''
          vim.keymap.set("i", '<Tab>', function()
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            end
            return "<tab>"
          end, {
            silent = true,
            expr = true;
          })
          vim.keymap.set("i", '<c-e>', function()
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").dismiss()
            end
            return "<c-e>"
          end, {
            silent = true,
            expr = true;
          })
        '';
      };
    };
  };
}
