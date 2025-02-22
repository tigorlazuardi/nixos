{ unstable, ... }:
{
  programs.nixvim = {
    extraPackages = with unstable; [ shfmt ];
    plugins.conform-nvim.settings.formatters_by_ft = {
      zsh = [ "shfmt" ];
      bash = [ "shfmt" ];
      sh = [ "shfmt" ];
    };
  };
}
