{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
  rose-pine-hyprcursor = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "rose-pine-hyprcursor";
    version = "0.3.2";
    src = pkgs.fetchFromGitHub {
      owner = "ndom91";
      repo = "rose-pine-hyprcursor";
      rev = "d2c0e6802f0ed1e7c638bb27b5aa8587b578d083";
      sha256 = "sha256-ArUX5qlqAXUqcRqHz4QxXy3KgkfasTPA/Qwf6D2kV0U=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/icons/rose-pine-hyprcursor
      cp -R . $out/share/icons/rose-pine-hyprcursor/

      runHook postInstall
    '';

    meta = with lib; {
      description = "Soho vibes for Cursors";
      downloadPage = "https://github.com/ndom91/rose-pine-hyprcursor/releases";
      homepage = "https://rosepinetheme.com/";
      license = licenses.gpl3;
      maintainers = with maintainers; [ ndom91 ];
    };
  });
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      rose-pine-hyprcursor
    ];
    home.sessionVariables = {
      HYPRCURSOR_THEME = "rose-pine-hyprcursor";
      HYPRCURSOR_SIZE = "28";
    };
  };
}
