{ pkgs, ... }:
{
  programs.starship =
    let
      flavour = "mocha";
      catppuccin-starship-repo = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "starship";
        rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f"; # Replace with the latest commit hash
        sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
      };
    in
    {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        scan_timeout = 10;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✘](bold red)";
        };
        format = "$all";
        directory = {
          truncation_length = 8;
          truncation_symbol = "…/";
          truncate_to_repo = false;
        };
        username = {
          show_always = true;
          format = "\\[[$user]($style)@";
        };
        hostname = {
          ssh_only = false;
          format = "[$ssh_symbol$hostname]($style)\\] ";
        };
        palette = "catppuccin_${flavour}";
      } // builtins.fromTOML (builtins.readFile (catppuccin-starship-repo + /palettes/${flavour}.toml));
    };
}
