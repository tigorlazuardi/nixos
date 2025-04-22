{
  inputs,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    # viAlias = true;
    # vimAlias = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  environment.systemPackages = with pkgs; [
    git
    neofetch
    curl
    wget
    lm_sensors # for sensors command
    nnn
    killall
    gnumake
    sqlite
    nurl
    lsof
    unzip
    openssl
    libcap
    fd
    du-dust
  ];

  environment.sessionVariables = {
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  programs.zsh.enable = true;
}
