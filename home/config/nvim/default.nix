{ config, pkgs, unstable, ... }:

{
  home.file.".config/nvim" = {
    source = ./.;
    recursive = true;
  };

  sops.secrets."copilot" = {
    path = "${config.home.homeDirectory}/.config/github-copilot/hosts.json";
  };

  home.packages = with pkgs; [
    stylua
    lua-language-server
    docker-compose-language-service
    emmet-ls
    silicon # For code screenshots

    ###### Golang development tools ######
    gomodifytags
    gotests
    iferr
    curl
    cargo
    nixpkgs-fmt
    nil

    gcc
    python3
  ];
}
