{ unstable, ... }:
{
  programs.nixvim = {
    plugins.none-ls.sources.formatting.nixfmt = {
      enable = true;
      package = unstable.nixfmt-rfc-style;
    };
    plugins.lsp.servers.nixd.enable = true;
  };
}
