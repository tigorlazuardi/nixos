{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.go;
  impl = pkgs.buildGoModule rec {
    pname = "impl";
    version = "1.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "josharian";
      repo = "impl";
      rev = "v${version}";
      sha256 = "sha256-0TSyg7YEPur+h0tkDxI3twr2PzT7tmo3shKgmSSJ6qk=";
    };
    vendorHash = "sha256-vTqDoM/LK5SHkayLKYig+tCrXLelOoILmQGCxlTWHog=";
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = true;
      goPrivate = [ "gitlab.bareksa.com" ];
    };
    home.packages = with pkgs; [
      # gotools

      ###### Golang development tools ######
      gomodifytags
      gotests
      iferr
      gopls
      gofumpt
      impl
      golangci-lint
      wgo
      delve
    ];

    home.file."go/bin" =
      let
        goPackages = with pkgs; [
          go
          wgo
          gotools
          gomodifytags
          gotests
          iferr
          gopls
          gofumpt
          impl
          golangci-lint
          delve
        ];
        merged = pkgs.symlinkJoin {
          name = "home-go-bin";
          paths = goPackages;
        };
      in
      {
        source = "${merged}/bin";
        recursive = true;
      };

    home.file."go/bin/gopls".source = "${pkgs.gopls}/bin/gopls";
    home.file."go/bin/dlv".source = "${pkgs.delve}/bin/dlv";
    home.file."go/bin/dlv-dap".source = "${pkgs.delve}/bin/dlv-dap";
    home.file."go/bin/impl".source = "${pkgs.impl}/bin/impl";

    # Some toolings will lookup for $GOROOT env.
    home.sessionVariables = {
      # GOROOT = "${config.programs.go.package}/share/go";
      GOPATH = "${config.home.homeDirectory}/go";
      GOEXPERIMENT = "rangefunc";
    };
  };
}
