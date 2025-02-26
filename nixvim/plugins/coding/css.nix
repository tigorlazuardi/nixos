{
  programs.nixvim = {
    plugins.lsp.servers.cssls.enable = true;
    plugins.conform-nvim.settings.formatters_by_ft.css = [ "prettierd" ];
  };
}
