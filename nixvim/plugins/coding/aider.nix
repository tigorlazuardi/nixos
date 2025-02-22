{ pkgs, inputs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-aider";
          version = inputs.nvim-aider.shortRev;
          src = inputs.nvim-aider;
        };
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-aider",
        cmd = {
          "AiderTerminalToggle",
          "AiderHealth",
        },
        keys = {
          { "<localleader>a", "<cmd>AiderTerminalToggle<cr>", desc = "Toggle Aider" },
          { "<localleader>A", "<cmd>AiderTerminalSend<cr>", desc = "Send to Aider", mode = { "n", "v" } },
          { "<localleader>s", "<cmd>AiderQuickAddFile<cr>", desc = "Add File to Aider" },
          { "<localleader>S", "<cmd>AiderQuickDropFile<cr>", desc = "Drop File from Aider" },
          { "<localleader>e", "<cmd>AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
          { "<localleader>b", "<cmd>AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
          { "<localleader>r", "<cmd>AiderQuickReadOnlyFile<cr>", desc = "Add File as Read-Only" },
        },
        after = function()
          require("nvim_aider").setup {
            win = {
              position = "right",
            },
          }
        end,
      }
    '';
  };
}
