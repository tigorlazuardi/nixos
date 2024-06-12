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
    docker-compose-language-service
    emmet-ls
    silicon # For code screenshots

    ###### Golang development tools ######
    gomodifytags
    gotests
    iferr
    curl

    gcc
    python3
  ];
}
