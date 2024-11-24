{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib) mkIf;
  gcalcliExec = (
    pkgs.writeShellScriptBin "gcalcli" ''
      client_id=$(cat ${config.sops.secrets."gcalcli/client/id".path})
      client_secret=$(cat ${config.sops.secrets."gcalcli/client/secret".path})
      ${pkgs.gcalcli}/bin/gcalcli --client-id=$client_id --client-secret=$client_secret "$@"
    ''
  );
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

    home.packages = with pkgs; [
      eww
      ags
      bun
      ags-agenda
      typescript
      (symlinkJoin {
        name = "gcalcli";
        paths = [
          gcalcliExec
          gcalcli
        ];
      })
    ];

    wayland.windowManager.hyprland.settings.exec-once = [ "ags-agenda" ];

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
