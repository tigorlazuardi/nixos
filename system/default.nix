{
  hardware-configuration,
  profile-path,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    profile-path
    hardware-configuration
    ./flatpak
    ./modules
    ./services
    ./podman
    ./programs.nix
    ./user.nix
    ./keyboard.nix
    ./bareksa
  ];

  security.sudo.wheelNeedsPassword = config.profile.security.sudo.wheelNeedsPassword;
  networking.hostName = config.profile.hostname;
  systemd.services.NetworkManager-wait-online.enable = !config.profile.networking.disableWaitOnline;

  nixpkgs.config.allowUnfree = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.extraOptions = ''
    http-connections = 8
    connect-timeout = 5
  '';

  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7d";
  # };

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

  documentation.enable = true;
  documentation.man = {
    man-db.enable = false;
    generateCaches = true;
    mandoc.enable = true;
  };

  system.stateVersion = config.profile.system.stateVersion;

  systemd.services.decrypt-sops = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''/run/current-system/activate'';
      Type = "oneshot";
      Restart = "on-failure"; # because oneshot
      RestartSec = "10s";
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots"; # --nogcroots prevents direnv caches from being deleted
    clean.dates = "weekly";
    flake = "/home/${config.profile.user.name}/dotfiles";
  };

  environment.variables.FLAKE = "/home/${config.profile.user.name}/dotfiles";

  environment.systemPackages = with pkgs; [
    # Tools for nh
    nix-output-monitor
    nvd
    nixfmt-rfc-style
    nixd
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  services.dbus.implementation = "broker";
}
