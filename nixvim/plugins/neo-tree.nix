{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-window-picker";
          src = pkgs.fetchFromGitHub {
            owner = "s1n7ax";
            repo = "nvim-window-picker";
            rev = "v2.4.0";
            hash = "sha256-ZavIPpQXLSRpJXJVJZp3N6QWHoTKRvVrFAw7jekNmX4=";
          };
          version = "2.4.0";
          doCheck = false;
          doInstallCheck = false;
        };
      }
    ];
    extraConfigLua = ''
      do
        require("window-picker").setup()
      end
    '';
    plugins.neo-tree = {
      enable = true;
      extraOptions = {
        filesystem = {
          filtered_items = {
            visible = true;
            never_show_by_pattern = [
              ".aider*"
            ];
          };
          never_show = [
            ".DS_Store"
            ".git"
            ".hg"
            ".svn"
            "thumbs.db"
          ];
        };
        window.mappings = {
          "<space>" = false;
          "b" = "next_source";
          "[b" = "prev_source";
          o = "open";
          l = "open";
          h = "close_node";
        };
      };
    };
    keymaps = [
      {
        action = "<cmd>Neotree toggle reveal focus<cr>";
        key = "<leader>e";
        mode = "n";
        options.desc = "Toggle Neo-tree";
      }
      {
        action = "<cmd>Neotree toggle buffers focus<cr>";
        key = "<leader>bb";
        mode = "n";
        options.desc = "Neo-tree buffers";
      }
    ];
  };
}
