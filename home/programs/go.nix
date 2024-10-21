{
  config,
  lib,
  pkgs,
  unstable,
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
      package = unstable.go_1_23;
    };
    home.packages = with pkgs; [
      gotools

      ###### Golang development tools ######
      gomodifytags
      gotests
      iferr
      unstable.gopls
      gofumpt
      impl
      golangci-lint
    ];

    # Some toolings will lookup for $GOROOT env.
    home.sessionVariables = {
      GOROOT = "${config.programs.go.package}/share/go";
      GOPATH = "${config.home.homeDirectory}/go";
      GOEXPERIMENT = "rangefunc";
    };
  };
}
