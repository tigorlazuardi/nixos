{
  unstable,
  pkgs,
  config,
  ...
}:
{
  programs.nixvim = {
    extraFiles."queries/go/injections.scm".text =
      # query
      ''
        ; extends

        ; This injection provide syntax highlighting for variable declaration and arguments by
        ; using the comment before the target string as the language.
        ;
        ; The dot after @injection.language ensures only comment text left to the target string will
        ; trigger injection.
        ;
        ; Example:
        ;   const foo = /* sql */ "SELECT * FROM table"
        ;   const foo = /* sql */ `SELECT * FROM table`
        ;   foo := /* sql */ "SELECT * from table"
        ;   foo := /* sql */ `SELECT * from table`
        ;   db.Query(/* sql */ "SELECT * from table")
        ;   db.Query(/* sql */ `SELECT * from table`)
        (
          [
            ; const foo = /* lang */ "..."
            ; const foo = /* lang */ `...`
            (
              const_spec
                (comment) @injection.language .
                value: (expression_list 
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
                )
            )
            ; foo := /* lang */ "..."
            ; foo := /* lang */ `...`
            (
              short_var_declaration
                (comment) @injection.language .
                right: (expression_list
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; var foo = /* lang */ "..."
            ; var foo = /* lang */ `...`
            (
              var_spec
                (comment) @injection.language .
                value: (expression_list
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; fn(/*lang*/ "...")
            ; fn(/*lang*/ `...`)
            (
              argument_list
                (comment) @injection.language .
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
            )
            ; []byte(/*lang*/ "...")
            ; []byte(/*lang*/ `...`)
            (
              type_conversion_expression
                (comment) @injection.language .
                operand:  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
            )
            ; []Type{ /*lang*/ "..." }
            ; []Type{ /*lang*/ `...` }
            (
              literal_value
              (comment) @injection.language .
              (literal_element
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; map[Type]Type{ key: /*lang*/ "..." }
            ; map[Type]Type{ key: /*lang*/ `...` }
            (
              keyed_element
              (comment) @injection.language .
              value: (literal_element
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
          ]
          (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
        )
      '';
    extraPackages = with pkgs; [
      gotools
      go-tools
      impl
      golangci-lint
      gomodifytags
      delve
      wgo
      gofumpt
    ];

    # Somehow something sets PATH env to use older version of Go.
    extraConfigLuaPost = ''
      vim.env.PATH = "${pkgs.go}/bin" .. ":" .. vim.env.PATH
    '';
    autoCmd = [
      {
        callback.__raw = # lua
          ''
            function()
              vim.opt_local.tabstop = 4
              vim.opt_local.shiftwidth = 4
              vim.opt_local.softtabstop = 4
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
      vim.filetype.add {
        extension = {
          templ = "templ",
          gotmpl = "gotmpl",
          gotxt = "gotmpl",
        },
      }

      require("lz.n").load {
        "goimpl.nvim",
        ft = "go",
        after = function()
          require("telescope").load_extension "goimpl"
          vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("GoImpl", {}),
            callback = function(ctx)
              local client = vim.lsp.get_client_by_id(ctx.data.client_id) or {}
              if client.name == "gopls" then
                vim.api.nvim_buf_create_user_command(
                  ctx.buf,
                  "Impl",
                  [[Telescope goimpl]],
                  {}
                )
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
            shadow = false;
            fillreturns = true;
            nonewvars = true;
            unusedwrite = true;
          };
          experimentalWorkspaceModule = true;
          experimentalTemplateSupport = true;
          usePlaceholders = false;
          completeUnimported = true;
          staticcheck = true;
          directoryFilters = [
            "-.git"
            "-.vscode"
            "-.idea"
            "-.vscode-test"
            "-node_modules"
            "-.direnv"
          ];
          semanticTokens = false;
        };
      };
      extraOptions = {
        capabilities.__raw = ''
          require("blink.cmp").get_lsp_capabilities({}, true)
        '';
        root_dir.__raw = # lua
          ''
            function(fname)
              local mod_cache = [[/home/${config.profile.user.name}/go/pkg/mod]]
              if fname:sub(1, #mod_cache) == mod_cache then
                local clients = vim.lsp.get_active_clients { name = "gopls" }
                if #clients > 0 then
                  return clients[#clients].config.root_dir
                end
              end
              return require("lspconfig.util").root_pattern("go.mod", ".git", "go.work")(fname)
            end
          '';
      };
    };
    plugins.neotest.adapters.golang = {
      enable = true;
      package = unstable.vimPlugins.neotest-golang;
    };
    plugins.conform-nvim.settings.formatters_by_ft.go = [
      "goimports"
      "gofumpt"
    ];
  };
}
