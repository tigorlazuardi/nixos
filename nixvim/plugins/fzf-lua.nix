{ unstable, ... }:
{
  # programs.nixvim = {
  #   extraPackages = with unstable; [
  #     fd
  #     ripgrep
  #     ueberzug
  #     delta
  #     universal-ctags
  #     (buildGoModule rec {
  #       pname = "ctags-lsp";
  #       version = "0.6.1";
  #       src = fetchFromGitHub {
  #         owner = "netmute";
  #         repo = "ctags-lsp";
  #         rev = "v${version}";
  #         hash = "sha256-wSccfhVp1PDn/gj46r8BNskEuBuRIx1wydYAW1PV4cg=";
  #       };
  #       vendorHash = null;
  #     })
  #   ];
  #   extraPlugins = with unstable; [
  #     {
  #       plugin = vimPlugins.vim-gutentags;
  #       optional = true;
  #     }
  #     {
  #       plugin =
  #         let
  #           src = fetchFromGitHub {
  #             owner = "netmute";
  #             repo = "ctags-lsp.nvim";
  #             rev = "aaae7b5d8dc7aeb836c63301b8eb7311af49bb2a";
  #             hash = "sha256-AlTDny/eaBJpxnIenU5ynaRUkPrXJLh4CduiOzdCAxo=";
  #           };
  #         in
  #         vimUtils.buildVimPlugin {
  #           pname = "ctags-lsp.nvim";
  #           version = src.rev;
  #           inherit src;
  #         };
  #       optional = true;
  #     }
  #   ];
  #   extraConfigLua = ''
  #     require('lz.n').load({
  #       {
  #         "ctags-lsp.nvim",
  #         event = { "BufReadPost", "BufNewFile", "BufWritePost" };
  #         after = function()
  #           require("lspconfig").ctags_lsp.setup({})
  #         end;
  #       };
  #       {
  #         "vim-gutentags",
  #         event = { "BufReadPost", "BufNewFile", "BufWritePost" };
  #       }
  #     })
  #   '';
  #   plugins.fzf-lua = {
  #     package = unstable.vimPlugins.fzf-lua;
  #     enable = true;
  #     settings = {
  #       fzf_colors = true;
  #       fzf_opts."--no-scrollbar" = true;
  #       defaults.formatter = "path.dirname_first";
  #       previewers.builtin = {
  #         extensions =
  #           let
  #             imgPreview = [ "ueberzug" ];
  #           in
  #           {
  #             png = imgPreview;
  #             jpg = imgPreview;
  #             jpeg = imgPreview;
  #             gif = imgPreview;
  #             webp = imgPreview;
  #           };
  #         ueberzug_scaler = "fit_contain";
  #       };
  #       winopts = {
  #         width = 0.8;
  #         height = 0.8;
  #         row = 0.5;
  #         col = 0.5;
  #         preview.scrollchars = [
  #           "┃"
  #           ""
  #         ];
  #       };
  #       files = {
  #         cwd_prompt = false;
  #         actions = {
  #           "alt-i" = {
  #             __unkeyed-1.__raw = ''require("fzf-lua").actions.toggle_ignore'';
  #           };
  #           "alt-h" = {
  #             __unkeyed-1.__raw = ''require("fzf-lua").actions.toggle_hidden'';
  #           };
  #         };
  #       };
  #     };
  #     lazyLoad.settings = {
  #       cmd = [ "FzfLua" ];
  #       keys =
  #         let
  #           map =
  #             key: action:
  #             {
  #               mode ? [ "n" ],
  #               desc ? "",
  #             }:
  #             {
  #               __unkeyed-1 = key;
  #               __unkeyed-2 = action;
  #               inherit mode desc;
  #             };
  #         in
  #         [
  #           (map "<leader>st" "<cmd>FzfLua tags_grep_cword<cr>" { desc = "Tags: grep under word"; })
  #           (map "<leader>sT" "<cmd>FzfLua tags<cr>" { desc = "Tags: grep"; })
  #           (map "gr" "<cmd>FzfLua lsp_references<cr>" { desc = "LSP References"; })
  #           (map "gd" "<cmd>FzfLua lsp_definitions<cr>" { desc = "LSP Definitions"; })
  #           (map "gI" "<cmd>FzfLua lsp_implementations<cr>" { desc = "LSP Implementations"; })
  #           (map "gS" "<cmd>FzfLua lsp_workspace_symbols<cr>" { desc = "LSP Workspace Symbols"; })
  #           (map "gy" "<cmd>FzfLua lsp_typedefs<cr>" { desc = "LSP Type Definition"; })
  #           (map "*" "<cmd>FzfLua grep_cword<cr>" { desc = "Grep word under cursor"; })
  #         ];
  #     };
  #   };
  # };
}
