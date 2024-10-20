{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.meta) getExe;
  cfg = config.profile.discord;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
    ];

    home.file = {
      ".config/discord/settings.json".text = builtins.toJSON {
        SKIP_HOST_UPDATE = true;
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [
      "sleep 10; until ${pkgs.unixtools.ping}/bin/ping -c 1 discord.com; do sleep 1; done; vesktop"
    ];

    services.swaync.settings.scripts._10-discord =
      let
        script = pkgs.callPackage ../../scripts/hyprland/focus-window.nix { };
      in
      {
        app-name = "(?=discord|vesktop)";
        exec = "${getExe script}";
        run-on = "action";
      };
  };
}
