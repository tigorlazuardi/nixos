{ pkgs, unstable, ... }:
{
  imports = [
    ./autostart.nix
    ./git.nix
    ./mpv.nix
    ./node.nix
    ./starship.nix
    ./tofi.nix
    ./vscode.nix
    ./zsh.nix
    ./discord.nix
    ./neovide.nix
    ./slack.nix
    ./whatsapp.nix
  ];

  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f";
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  programs.ripgrep.enable = true;

  programs.go = {
    enable = true;
    goPrivate = [
      "gitlab.bareksa.com"
    ];
    package = unstable.go_1_22;
  };

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "jinjaccalgkegednnccohejagnlnfdag"; } # violent monkey
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsor block
      { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; } # privacy badger
      { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # cookie auto delete
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Integration
    ];
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  programs.nnn = {
    enable = true;
  };

  programs.htop.enable = true;

  programs.mpv.enable = true;

  home.packages = with pkgs; [
    unstable.gh # github cli
    wget
    curl
    openssl
    zig
    unzip
    libcap
    gcc
    cargo
    nixpkgs-fmt
    fd
    wl-clipboard
    unstable.dbeaver-bin
    unstable.jellyfin-media-player
    stylua
    luarocks
    du-dust
    just
    modd
    lefthook
    spotify
    # seafile-client
    lsof
    # scrcpy
    masterpdfeditor4
    watchexec
    kcalc
    pdfarranger
    unstable.microsoft-edge
    # (floorp.override {
    #   nativeMessagingHosts = with pkgs; [
    #     plasma5Packages.plasma-browser-integration
    #   ];
    # })
    nextcloud-client
    # qownnotes
  ];
}
