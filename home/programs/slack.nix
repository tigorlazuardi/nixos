{ pkgs, lib, config, ... }:
let
  cfg = config.profile.slack;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ slack ];

    systemd.user = lib.mkIf cfg.autostart {
      # Unlike Discord, Slack is only used on office hours,
      # so we will use a timer to start it on office hours only.
      timers.slack = {
        Unit = {
          Description = "Start Slack Desktop Client on Weekdays on Login";
        };
        Timer = {
          OnCalendar = "Mon..Fri 09..18:*:*";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      services.slack = {
        Unit = {
          Description = "Slack Desktop Client";
          Wants = [ "graphical.target" ];
          StartLimitIntervalSec = 300;
          StartLimitBurst = 10;
        };
        Service =
          let
            bash = "${pkgs.bash}/bin/bash";
            ping = "${pkgs.unixtools.ping}/bin/ping";
            host = "google.com"; # slack.com does not respond to ping
            sleep = "${pkgs.coreutils}/bin/sleep";
            slack = "${pkgs.slack}/bin/slack";
            exec = ''${bash} -c "until ${ping} -c 1 ${host}; do ${sleep} 1; done; ${slack}"'';
          in
          {
            Type = "simple";
            ExecStartPre = "${sleep} 5";
            ExecStart = exec;
            Restart = "on-failure";
            # Prevent Slack from auto-restarting when user closes it.
            # The timer setup above will trigger this service
            # if RemaiAfterExit is not set to "yes".
            #
            # This will mark the service as still "Active" by systemd
            # hence the timer will not trigger the service again.
            RemainAfterExit = "yes";
            Environment = [ "NIXOS_OZONE_WL=1" ];
          };
      };
    };
  };
}
