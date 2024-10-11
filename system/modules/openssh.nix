{ config, lib, pkgs, ... }:
let
  cfg = config.profile.openssh;
  inherit (lib.meta) getExe;
in
lib.mkMerge [
  (lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.mkAfter [ 22 ];
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        UseDns = false;
        X11Forwarding = false;
        PermitRootLogin = "no";
        GSSAPIAuthentication = false;
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

    sops.secrets."ntfy/tokens/homeserver" = { sopsFile = ../../secrets/ntfy.yaml; };
    sops.templates."ntfy-ssh-login.sh" = {
      content = builtins.readFile (lib.meta.getExe (pkgs.writeShellScriptBin "ntfy-ssh-login.sh" /*sh*/ ''
        if [ "$PAM_TYPE" == "open_session" ]; then
            ${getExe pkgs.curl} -X POST \
                -H "X-Priority: 4" \
                -H "X-Tags: warning" \
                -H "Authorization: Bearer ${config.sops.placeholder."ntfy/tokens/homeserver"}" \
                -d "SSH login: $PAM_USER from $PAM_RHOST" \
                https://ntfy.tigor.web.id/ssh
        fi
      ''));
    };

    security.pam.services.sshd.text = lib.mkDefault (lib.mkAfter ''
      session optional pam_exec.so ${getExe pkgs.bash} ${config.sops.templates."ntfy-ssh-login.sh".path}
    '');
  })
  {
    profile.services.ntfy-sh.client.settings.subscribe = [
      {
        topic = "ssh";
      }
    ];
  }
]
