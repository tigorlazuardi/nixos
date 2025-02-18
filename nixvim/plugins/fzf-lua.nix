{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [
      fd
      ripgrep
      ueberzug
      delta
    ];
    plugins.fzf-lua = {
      package = unstable.vimPlugins.fzf-lua;
      enable = true;
      settings = {
        fzf_colors = true;
        fzf_opts."--no-scrollbar" = true;
        defaults.formatter = "path.dirname_first";
        previewers.builtin = {
          extensions =
            let
              imgPreview = [ "ueberzug" ];
            in
            {
              png = imgPreview;
              jpg = imgPreview;
              jpeg = imgPreview;
              gif = imgPreview;
              webp = imgPreview;
            };
          ueberzug_scaler = "fit_contain";
        };
        ui_select.__raw = ''
          function(fzf_opts, items)
            return vim.tbl_deep_extend("force", fzf_opts, {
              prompt = " ",
              winopts = {
                title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                title_pos = "center",
              },
            }, fzf_opts.kind == "codeaction" and {
              winopts = {
                layout = "vertical",
                -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
                width = 0.5,
                preview = not vim.tbl_isempty(LazyVim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                  layout = "vertical",
                  vertical = "down:15,border-top",
                  hidden = "hidden",
                } or {
                  layout = "vertical",
                  vertical = "down:15,border-top",
                },
              },
            } or {
              winopts = {
                width = 0.5,
                -- height is number of items, with a max of 80% screen height
                height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
              },
            })
          end
        '';
        winopts = {
          width = 0.8;
          height = 0.8;
          row = 0.5;
          col = 0.5;
          preview.scrollchars = [
            "┃"
            ""
          ];
        };
        files = {
          cwd_prompt = false;
          actions = {
            "alt-i" = {
              __unkeyed-1.__raw = ''require("fzf-lua").actions.toggle_ignore'';
            };
            "alt-h" = {
              __unkeyed-1.__raw = ''require("fzf-lua").actions.toggle_hidden'';
            };
          };
        };
      };
      lazyLoad.settings = {
        cmd = [ "FzfLua" ];
        keys =
          let
            map =
              key: action:
              {
                mode ? [ "n" ],
                desc ? "",
              }:
              {
                __unkeyed-1 = key;
                __unkeyed-2 = action;
                inherit mode desc;
              };
          in
          [
            (map "<leader><leader>" "<cmd>FzfLua files<cr>" { desc = "Search Files"; })
            (map "<leader>sg" "<cmd>FzfLua grep<cr>" { desc = "Grep"; })
            (map "<leader>st" "<cmd>FzfLua tags_grep_cword<cr>" { desc = "Tags: grep under word"; })
            (map "<leader>sT" "<cmd>FzfLua tags<cr>" { desc = "Tags: grep"; })
            (map "gr" "<cmd>FzfLua lsp_references<cr>" { desc = "LSP References"; })
            (map "gd" "<cmd>FzfLua lsp_definitions<cr>" { desc = "LSP Definitions"; })
            (map "gI" "<cmd>FzfLua lsp_implementations<cr>" { desc = "LSP Implementations"; })
            (map "gS" "<cmd>FzfLua lsp_workspace_symbols<cr>" { desc = "LSP Workspace Symbols"; })
            (map "gy" "<cmd>FzfLua lsp_typedefs<cr>" { desc = "LSP Type Definition"; })
            (map "*" "<cmd>FzfLua grep_cword<cr>" { desc = "Grep word under cursor"; })
          ];
      };
    };
  };
}
