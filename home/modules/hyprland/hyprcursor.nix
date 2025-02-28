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
  future-cyan-hyprcursor = pkgs.stdenv.mkDerivation (finalAttrs: rec {
    pname = "future-cyan-hyprcursor";
    version = "60fc69d603a6d7b99c1841a2c4cebd130b1aa357";
    src = pkgs.fetchFromGitLab {
      owner = "Pummelfisch";
      repo = "future-cyan-hyprcursor";
      rev = version;
      sha256 = "sha256-TRDSQFCwofNj3PbGdE4Ro1hyQV7nJuE2Gc7YSUvv4k0=";
    };
    installPhase = ''
      runHook preInstall

      tgtDir=Future-Cyan-Hyprcursor_Theme
      mkdir -p "$out/share/icons/$tgtDir"
      cp -R "./$tgtDir" "$out/share/icons/$tgtDir/"

      runHook postInstall
    '';
  });
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      rose-pine-hyprcursor
      future-cyan-hyprcursor
    ];
    home.sessionVariables = {
      HYPRCURSOR_THEME = "rose-pine-hyprcursor";
    };
  };
}
