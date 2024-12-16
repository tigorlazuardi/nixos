{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    sops.secrets =
      let
        sopsFile = ../../../secrets/gcalcli.yaml;
      in
      {
        "gcalcli/client/id" = {
          inherit sopsFile;
        };
        "gcalcli/client/secret" = {
          inherit sopsFile;
        };
      };

    # documentation for symlinkJoin: https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
    home.packages = with pkgs; [
      ags-agenda
      (symlinkJoin {
        name = "gcalcli";
        paths = [
          (writeShellScriptBin "gcalcli" ''
            client_id=$(cat ${config.sops.secrets."gcalcli/client/id".path})
            client_secret=$(cat ${config.sops.secrets."gcalcli/client/secret".path})
            ${pkgs.gcalcli}/bin/gcalcli --client-id=$client_id --client-secret=$client_secret "$@"
          '')
          gcalcli
        ];
      })
    ];

    # wayland.windowManager.hyprland.settings.exec-once = [ "ags-agenda" ];

    home.file.".config/gcalcli/config.toml".source = (pkgs.formats.toml { }).generate "config.toml" {
      calendars = {
        default-calendars = [
          "tigor.hutasuhut@bareksa.com"
          "Holidays in Indonesia"
          "Engineering Team"
        ];
      };

      output = {
        week-start = "monday";
      };
    };
  };
}
