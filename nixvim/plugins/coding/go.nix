{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [
      gotools
      go-tools
      impl
      go
      gofumpt
      golangci-lint
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

    plugins.conform-nvim.settings.formatters_by_ft.go = [
      "goimports"
      "gofumpt"
    ];
    plugins.lsp.servers.golangci_lint_ls = {
      enable = true;
      package = unstable.golangci-lint-langserver;
    };
    plugins.lsp.servers.gopls = {
      enable = true;
      package = unstable.gopls;
    };
  };
}
