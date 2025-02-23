{ unstable, ... }:
{
  programs.nixvim.keymaps = [
    {
      key = "<S-Enter>";
      action.__raw = ''
        function()
          require('noice').redirect(vim.fn.getcmdline())
        end
      '';
      mode = "c";
      options.desc = "Redirect CMDLine";
    }
  ];
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
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        redirect.view = "split";
        views.split = {
          position = "right";
          size = "33%";
        };
        hover.silent = true;
        presets = {
          lsp_doc_border = true;
          bottom_search = true;
          # command_pallete = true;
          long_message_to_split = true;
          inc_rename = false;
        };
        routes = [
          # temporarily disable vim.tbl_islist is deprecated until neovim
          # 0.11 stable is released
          {
            filter = {
              event = "msg_show";
              find = "vim.tbl_islist is deprecated";
            };
            opts.skip = true;
          }
        ];
      };
    };
  };
}
