{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [
      gotools
      go-tools
      impl
      golangci-lint
      goimports-reviser
      go
    ];

    plugins.conform-nvim.settings.formatters_by_ft.go = [ "goimports-reviser" ];
    plugins.lint.lintersByFt.go = [ "golangcilint" ];
    plugins.lsp.servers.gopls = {
      enable = true;
      package = unstable.gopls;
    };
  };
}
