{ hardware-configuration, profile-path, config, ... }:
{
  imports = [
    profile-path
    hardware-configuration
    ./modules
    ./programs.nix
    ./user.nix
    ./keyboard.nix
  ];

  security.sudo =
    let
      cfg = config.profile.security.sudo;
    in
    {
      wheelNeedsPassword = cfg.wheelNeedsPassword;
      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults timestamp_type=global
      '';
    };
  networking.hostName = config.profile.hostname;


  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''
    http-connections = 8
    connect-timeout = 5
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  time.timeZone = "Asia/Jakarta";

  documentation.man = {
    man-db.enable = false;
    generateCaches = true;
    mandoc.enable = true;
  };

  system.stateVersion = "23.11"; # Did you read the comment?

  systemd.services.decrypt-sops = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''/run/current-system/activate'';
      Type = "oneshot";
      Restart = "on-failure"; # because oneshot
      RestartSec = "10s";
    };
  };
}
