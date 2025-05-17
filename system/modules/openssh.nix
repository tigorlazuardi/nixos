{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.openssh;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.mkAfter [ 22 ];
      extraCommands =
        let
          # repeat offenders.
          blocked_ips = [
            "218.92.0.148" # Some chinese ip
            "45.140.17.124" # some russian ip
            "182.53.220.26" # Some thai ip
            "78.187.21.105" # Some turkish ip
            "103.186.1.120" # Some bandung IP
            "106.75.191.225"
          ];
        in
        # Block repeat offenders
        lib.strings.concatMapStringsSep "\n" (
          ip: "iptables -I INPUT -s ${ip} -p tcp --dport ssh -j DROP"
        ) blocked_ips;
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        UseDns = false;
        X11Forwarding = false;
        PermitRootLogin = "no";
        # GSSAPIAuthentication = false;
      };
    };
    services.fail2ban = {
      enable = true;
      # Ban IP after 5 failures
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
    };

    profile.services.ntfy-sh.client.settings.subscribe = [
      {
        command = ''${pkgs.libnotify}/bin/notify-send --app-name="openssh" --icon="${./ssh-svgrepo-com.svg}" --category=im.received --urgency=normal "$title" "$message"'';
        topic = "ssh";
      }
    ];
  };
}
