{ unstable, ... }:
{
  programs.nixvim.plugins = {
    notify = {
      enable = true;
      # disable overriding vim.notify with require('notify')
      luaConfig.pre = unstable.lib.mkForce "";
      lazyLoad.settings.ft = [ ];
      settings = {
        render = "minimal";
      };
    };
    noice = {
      enable = true;
      package = unstable.vimPlugins.noice-nvim;
      lazyLoad.settings.event = [ "DeferredUIEnter" ];
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        lsp.progress.enabled = false;
        hover.silent = true;
        messages = {
          view = "mini";
          view_error = "mini";
          view_warn = "mini";
          view_history = "messages";
        };
        notify.view = "mini";
        message.view = "mini";
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
              ];
            };
            view = "mini";
          }
        ];
        presets = {
          lsp_doc_border = true;
          bottom_search = true;
          # command_pallete = true;
          long_message_to_split = true;
          inc_rename = false;
        };
      };
    };
  };
}
