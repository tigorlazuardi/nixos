{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [ nixfmt-rfc-style ];
    plugins.conform-nvim.settings.formatters_by_ft.nix = [
      "injected"
      "nixfmt"
    ];
    plugins.lsp.servers.nixd.enable = true;
  };
}
