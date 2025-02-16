{
  # This file only enables lspconfig
  #
  # Configuration should be set in relevant files for
  # locality of behavior.
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
    };
  };
}
