{ ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.file.".config/wezterm" = {
    source = ./.;
    recursive = true;
  };
}
