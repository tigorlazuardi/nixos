{ pkgs, ... }:
{
  home.packages = with pkgs; [
    variety
    bitwarden
  ];

  home.file = {
    ".config/autostart/variety.desktop" = {
      source = "${pkgs.variety}/share/applications/variety.desktop";
    };

    ".config/autostart/bitwarden.desktop" = {
      source = "${pkgs.bitwarden}/share/applications/bitwarden.desktop";
    };
  };
}
