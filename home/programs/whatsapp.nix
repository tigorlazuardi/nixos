{ lib, config, pkgs, unstable, ... }:
let
  cfg = config.profile.whatsapp;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.whatsapp-for-linux ];

    systemd.user = lib.mkIf cfg.autostart {
      services.whatsapp = {
        Unit = {
          Description = "WhatsApp for Linux";
          Wants = [ "graphical.target" ];
          After = [ "nss-lookup.target" ];
          StartLimitIntervalSec = 300;
          StartLimitBurst = 10;
        };
        Service =
          let
            bash = "${pkgs.bash}/bin/bash";
            ping = "${pkgs.unixtools.ping}/bin/ping";
            host = "web.whatsapp.com";
            sleep = "${pkgs.coreutils}/bin/sleep";
            whatsapp = "${unstable.whatsapp-for-linux}/bin/whatsapp-for-linux";
            exec = ''${bash} -c "until ${ping} -c 1 ${host}; do ${sleep} 1; done; ${whatsapp}"'';
          in
          {
            Type = "simple";
            ExecStartPre = "${sleep} 10";
            ExecStart = exec;
            Restart = "on-failure";
            RemainAfterExit = "yes";
          };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
