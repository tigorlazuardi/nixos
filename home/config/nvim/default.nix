{ pkgs, unstable, ... }:

{
  home.file.".config/nvim" = {
    source = ./.;
    recursive = true;
  };

  home.packages = with pkgs; [
    docker-compose-language-service
    emmet-ls
    # golangci-lint-langserver
    silicon # For code screenshots

    ###### Golang development tools ######
    gomodifytags
    gotests
    iferr
    curl

    unstable.lua-language-server
  ];
}
