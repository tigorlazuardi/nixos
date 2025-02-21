{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [
      gotools
      go-tools
      impl
      golangci-lint
      gomodifytags
      delve
    ];
    autoCmd = [
      {
        callback.__raw = ''
          function()
            vim.opt_local.tabstop = 4;
            vim.opt_local.shiftwidth = 4;
            vim.opt_local.softtabstop = 4;
          end
        '';
        event = "FileType";
        pattern = "go";
      }
    ];

    extraPlugins = [
      {
        plugin =
          let
            src = unstable.fetchFromGitHub {
              owner = "edolphin-ydf";
              repo = "goimpl.nvim";
              rev = "61257826f31a79870bb13d56c4edd09b1291c0b8";
              hash = "sha256-4kmvNdyA+by/jgo9CGNljND3AcLYgw0byfIQsSz8M2Y=";
            };
          in
          unstable.vimUtils.buildVimPlugin {
            pname = "goimpl.nvim";
            version = src.rev;
            inherit src;
          };
        optional = true;
      }
    ];

    extraConfigLua = ''
      require('lz.n').load {
        "goimpl.nvim",
        ft = "go",
        after = function()
          require("telescope").load_extension("goimpl") 
          vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("GoImpl", {}),
              callback = function(ctx)
                  local client = vim.lsp.get_client_by_id(ctx.data.client_id) or {}
                  if client.name == "gopls" then
                      vim.api.nvim_buf_create_user_command(ctx.buf, "Impl", [[Telescope goimpl]], {})
                      vim.keymap.set(
                          "n",
                          "<leader>ci",
                          [[<cmd>Telescope goimpl<cr>]],
                          { buffer = ctx.buf, desc = "Generate implementation stub" }
                      )
                  end
              end,
          })
        end,
      }
    '';

    plugins.lsp.servers.gopls = {
      enable = true;
      package = unstable.gopls;
      settings = {
        gopls = {
          gofumpt = true;
          codelenses = {
            gc_details = false;
            generate = true;
            regenerate_cgo = true;
            run_govulncheck = true;
            test = true;
            tidy = true;
            upgrade_dependency = true;
            vendor = true;
          };
          analyses = {
            nilness = true;
            unusedparams = true;
            shadow = true;
            fillreturns = true;
            nonewvars = true;
            unusedwrite = true;
          };
          usePlaceholders = true;
          completeUnimported = true;
          staticcheck = true;
          directoryFilters = [
            "-.git"
            "-.vscode"
            "-.idea"
            "-.vscode-test"
            "-node_modules"
          ];
          experimentalWorkspaceModule = true;
          semanticTokens = true;
        };
      };
      rootDir.__raw = ''require('lspconfig').util.root_pattern('go.mod', '.git', 'go.work')'';
    };
    plugins.neotest.adapters.golang = {
      enable = true;
      package = unstable.vimPlugins.neotest-golang;
    };
    plugins.none-ls.sources = {
      code_actions = {
        impl.enable = true;
        gomodifytags.enable = true;
      };
      diagnostics.golangci_lint = {
        enable = true;
        package = unstable.golangci-lint;
      };
      formatting = {
        gofumpt = {
          enable = true;
          package = unstable.gofumpt;
        };
        goimports = {
          enable = true;
          package = unstable.gotools;
        };
      };
    };
  };
}
