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
      lazyLoad.settings = {
        event = [ "DeferredUIEnter" ];
        keys = [
          {
            __unkeyed-1 = "<S-Enter>";
            __unkeyed-2.__raw = "function() require('noice').redirect(vim.fn.getcmdline()) end";
            desc = "Redirect CMDLine";
            mode = "c";
          }
        ];
      };
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        redirect.view = "split";
        views.split = {
          position = "right";
          size = "25%";
        };
        hover.silent = true;
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
