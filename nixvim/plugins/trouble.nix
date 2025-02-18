{ inputs, pkgs, ... }:
{
  programs.nixvim = {
    plugins.trouble = {
      enable = true;
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "trouble.nvim";
        src = inputs.trouble-nvim;
        version = inputs.trouble-nvim.shortRev;
      };
      settings = {
        modes = {
          diagnostics_buffer_auto = {
            mode = "diagnostics";
            warn_no_results = false;
            auto_close = true;
            filter.__raw = ''
              function(items)
                local current_buf_id = vim.api.nvim_get_current_buf()
                return vim.tbl_filter(function(item)
                  return item.bufnr == current_buf_id and item.severity == vim.diagnostic.severity.ERROR
                end, items)
              end
            '';
          };
        };
      };
      lazyLoad.settings = {
        cmd = "Trouble";
        keys =
          let
            map =
              key: action:
              {
                mode ? [ "n" ],
                desc ? null,
              }:
              {
                __unkeyed-1 = key;
                __unkeyed-2 = action;
                inherit mode desc;
              };
          in
          [
            (map "<leader>xx" "<cmd>Trouble diagnostics toggle<cr>" { desc = "Toggle diagnostics"; })
            (map "<leader>xX" "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" {
              desc = "Toggle diagnostics (Buffer)";
            })
            (map "<leader>xq" "<cmd>Trouble qflist toggle<cr>" { desc = "Quickfix list"; })
            (map "<leader>xl" "<cmd>Trouble loclist toggle<cr>" { desc = "Location List"; })
          ];
      };
    };
    autoCmd = [
      {
        event = [
          "InsertLeave"
          "BufEnter"
        ];
        callback.__raw = ''
          function()
            local trouble = require('trouble')
            if trouble.is_open() then
              return
            end
            trouble.open("diagnostics_buffer_auto")
          end
        '';
      }
    ];
  };
}
