{ pkgs, config, lib, ... }:
let
  cfg = config.profile.bitwarden;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden
    ];



    home.file = {
      ".config/autostart/bitwarden.desktop" = lib.mkIf cfg.autostart {
        source = "${pkgs.bitwarden}/share/applications/bitwarden.desktop";
      };
    };
  };
}
