{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.profile.discord;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
    ];

    systemd.user = lib.mkIf cfg.autostart {
      services.discord = {
        Unit = {
          Description = "Automatically start Discord on Login";
          # Only runs on sessions with a graphical target like X11 or Wayland.
          Wants = [ "graphical.target" ];
          # Only run after the network is online.
          After = [ "nss-lookup.target" ];
          StartLimitIntervalSec = 300;
          StartLimitBurst = 10;
        };
        Service =
          let
            bash = "${pkgs.bash}/bin/bash";
            ping = "${pkgs.unixtools.ping}/bin/ping";
            host = "discord.com";
            sleep = "${pkgs.coreutils}/bin/sleep";
            discord = "${pkgs.discord}/bin/discord";
            exec = ''${bash} -c "until ${ping} -c 1 ${host}; do ${sleep} 1; done; ${discord}"'';
          in
          {
            Type = "simple";
            ExecStartPre = "${sleep} 5";
            ExecStart = exec;
            Restart = "on-failure";
            RemainAfterExit = "yes";
            Environment = [ "NIXOS_OZONE_WL=1" ];
          };
        Install = {
          WantedBy = [ "default.target" ]; # After user login.
        };
      };
    };

    home.file = {
      ".config/discord/settings.json".text = ''
        {
            "SKIP_HOST_UPDATE": true
        }
      '';
    };
  };
}
