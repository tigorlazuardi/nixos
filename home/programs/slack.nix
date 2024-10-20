{ pkgs, lib, config, ... }:
let
  cfg = config.profile.slack;
  script = pkgs.writeShellScriptBin "slack.sh" ''
    sleep 10; until ${pkgs.unixtools.ping}/bin/ping -c 1 1.1.1.1; do sleep 1; done; slack
  '';
  scriptFile = lib.meta.getExe script;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ slack ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [
      scriptFile
    ];

    home.file.".config/autostart/slack.sh".source = lib.mkIf cfg.autostart scriptFile;
  };
}
