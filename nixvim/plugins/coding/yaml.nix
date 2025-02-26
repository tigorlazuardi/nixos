{
  programs.nixvim = {
    plugins.lsp.servers.yamlls = {
      enable = true;
      extraOptions.capabilities.__raw = ''
        require("blink.cmp").get_lsp_capabilities({}, true)
      '';
    };
    plugins.conform-nvim.settings.formatters_by_ft = {
      yaml = [ "prettierd" ];
    };
    plugins.schemastore.enable = true;
  };
}
