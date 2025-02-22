{ unstable, ... }: {
  programs.nixvim = {
    extraPackages = with unstable; [ nixfmt-classic ];
    plugins.conform-nvim.settings.formatters_by_ft.nix = [ "nixfmt" ];
    plugins.lsp.servers.nixd.enable = true;
  };
}
