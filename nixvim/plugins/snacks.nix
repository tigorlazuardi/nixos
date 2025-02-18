{
  inputs,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lazygit
    ];
    keymaps = [
      {
        action = "<cmd>lua Snacks.explorer()<cr>";
        key = "<leader>e";
        mode = "n";
        options.desc = "(Snacks) Open Explorer";
      }
      {
        action = "<cmd>lua Snacks.bufdelete()<cr>";
        key = "<leader>bd";
        mode = "n";
        options.desc = "Buffer Delete";
      }
      {
        action = "<cmd>lua Snacks.bufdelete.other()<cr>";
        key = "<leader>bo";
        mode = "n";
        options.desc = "Buffer Delete Others";
      }
      {
        action = "<cmd>lua Snacks.lazygit()<cr>";
        key = "<leader>z";
        mode = "n";
        options.desc = "Open Lazygit";
      }
      {
        action = "<cmd>lua Snacks.picker.files()<cr>";
        key = "<leader><leader>";
        mode = "n";
        options.desc = "File Picker";
      }
      {
        action = "<cmd>lua Snacks.picker.grep()<cr>";
        key = "<leader>sg";
        mode = "n";
        options.desc = "Search";
      }
    ];
    opts.statuscolumn = ''
      %!v:lua.require'snacks.statuscolumn'.get()
    '';
    autoCmd = [
      {
        callback.__raw = ''
          function(ev)
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(vim.lsp.status(), "info", {
              id = "lsp_progress",
              title = "LSP Progress",
              opts = function(notif)
                notif.icon = ev.data.params.value.kind == "end" and " "
                  or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end
        '';
        event = "LspProgress";
      }
    ];
    plugins.snacks = {
      enable = true;
      settings = {
        bigfile = {
          enabled = true;
        };
        dashboard = {
          enabled = false;
        };
        explorer = {
          enabled = true;
        };
        indent = {
          enabled = true;
        };
        input = {
          enabled = true;
        };
        picker = {
          enabled = true;
        };
        notifier = {
          enabled = true;
          style = "minimal";
          top_down = false;
        };
        quickfile = {
          enabled = true;
        };
        scope = {
          enabled = true;
        };
        scroll = {
          enabled = true;
        };
        statuscolumn = {
          enabled = true;
        };
        words = {
          enabled = true;
        };
      };
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "snacks-nvim";
        src = inputs.snacks-nvim;
        version = inputs.snacks-nvim.shortRev;
        dependencies = [
          (pkgs.vimUtils.buildVimPlugin {
            pname = "trouble-nvim";
            src = inputs.trouble-nvim;
            version = inputs.trouble-nvim.shortRev;
          })
        ];
      };
    };
  };
}
