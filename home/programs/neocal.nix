{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.profile.home.programs.neocal;
  inherit (lib) mkIf;
  neocal = pkgs.rustPlatform.buildRustPackage rec {
    pname = "neocal";
    version = "0.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "oscarmcm";
      repo = "neocal";
      rev = "v${version}";
      hash = "sha256-YEoGy41aPF4PjQ8jCWobbq14VQeDSEaJxqaOp7Re3Z0=";
    };
    cargoHash = "sha256-O4SUq4ZTykdLRp6JOnAHlhI2Mh747E5YMzokB2CCZ3c=";
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];
    buildInputs = with pkgs; [
      openssl
    ];
  };
in
{
  config = mkIf cfg.enable {
    home.packages = [ neocal ];

    sops.secrets."neocal/work/config.ini" = {
      sopsFile = ../../secrets/neocal.yaml;
      path = "${config.home.homeDirectory}/.config/neocal/config.ini";
    };
  };
}
