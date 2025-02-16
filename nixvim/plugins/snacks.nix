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
        action = "<cmd>lua Snacks.lazygit()<cr>";
        key = "<leader>z";
        mode = "n";
        options.desc = "Open Lazygit";
      }
    ];
    opts.statuscolumn = ''
      %!v:lua.require'snacks.statuscolumn'.get()
    '';
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
          enabled = false;
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
