{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.meta) getExe;
  cfg = config.profile.discord;
  autostartScript = pkgs.writeShellScriptBin "discord.sh" /*sh*/ ''
    sleep 10;
    until ${pkgs.unixtools.ping}/bin/ping -c 1 discord.com;
        do sleep 1;
    done; 
    vesktop
  '';
  autostartScriptFile = getExe autostartScript;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
    ];

    home.file.".config/discord/settings.json".text = builtins.toJSON {
      SKIP_HOST_UPDATE = true;
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [
      autostartScriptFile
    ];

    home.file.".config/autostart/discord.sh" = lib.mkIf cfg.autostart {
      source = autostartScriptFile;
    };

    services.swaync.settings.scripts._10-discord =
      let
        focusWindowScript = pkgs.callPackage ../../scripts/hyprland/focus-window.nix { };
      in
      {
        app-name = "(?=discord|vesktop)";
        exec = "${getExe focusWindowScript}";
        run-on = "action";
      };
  };
}
