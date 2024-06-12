{ lib, ... }:
{
  options.profile = {
    discord = {
      enable = lib.mkEnableOption "discord";
      autostart = lib.mkEnableOption "discord autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 7 silent,class:(discord)";
      };
    };

    slack = {
      enable = lib.mkEnableOption "slack";
      autostart = lib.mkEnableOption "slack autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 6 silent,class:(Slack)";
      };
    };

    whatsapp = {
      enable = lib.mkEnableOption "whatsapp";
      autostart = lib.mkEnableOption "whatsapp autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 5 silent,class:(whatsapp-for-linux)";
      };
    };

    syncthing.enable = lib.mkEnableOption "syncthing";

    obs.enable = lib.mkEnableOption "obs";
  };
}
