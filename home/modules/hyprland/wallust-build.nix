{ lib
, fetchFromGitea
, rustPlatform
, nix-update-script
, imagemagick
, makeWrapper
, pkgs
}:
rustPlatform.buildRustPackage rec {
  pname = "wallust";
  version = "3.0.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "explosion-mental";
    repo = "wallust";
    rev = version;
    hash = "sha256-vZTHlonepK1cyxHhGu3bVBuOmExPtRFrAnYp71Jfs8c=";
  };

  cargoHash = "sha256-o6VRekazqbKTef6SLjHqs9/z/Q70auvunP+yFDkclpg=";

  nativeBuildInputs = [ makeWrapper pkgs.rust-bin.stable."1.79.0".default ];

  postFixup = ''
    wrapProgram $out/bin/wallust \
      --prefix PATH : "${lib.makeBinPath [ imagemagick ]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A better pywal";
    homepage = "https://codeberg.org/explosion-mental/wallust";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onemoresuza iynaix ];
    downloadPage = "https://codeberg.org/explosion-mental/wallust/releases/tag/${version}";
    mainProgram = "wallust";
  };
}
