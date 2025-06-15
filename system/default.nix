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
    ./systemd.nix

    inputs.sops-nix.nixosModules.sops
    inputs.nur.modules.nixos.default
    inputs.nixvim.nixosModules.nixvim
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
    # inputs.stylix.nixosModules.stylix
    ../nixvim
  ];

  nixpkgs.overlays = [
    inputs.nur.overlays.default
    inputs.rust-overlay.overlays.default
    (import ../overlays)
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  security.sudo.wheelNeedsPassword = config.profile.security.sudo.wheelNeedsPassword;
  networking.hostName = config.profile.hostname;
  systemd.services.NetworkManager-wait-online.enable = !config.profile.networking.disableWaitOnline;

  nixpkgs.config.allowUnfree = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };
  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;
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

  environment.variables.NH_FLAKE = "/home/${config.profile.user.name}/dotfiles";

  environment.systemPackages = with pkgs; [
    # Tools for nh
    nix-output-monitor
    nvd
    nixfmt-rfc-style
    nixd
  ];

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 8 * 1024 * 1024; # QUIC server recommended values
    "net.core.rmem_max" = 8 * 1024 * 1024; # QUIC server recommended values
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  services.dbus.implementation = "broker";
}
