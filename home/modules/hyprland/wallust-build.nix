{ lib
, fetchFromGitea
, rustPlatform
, nix-update-script
, imagemagick
, makeWrapper
, pkgs
}:
let
  version = "3.0.0-beta";
in
rustPlatform.buildRustPackage {
  pname = "wallust";
  inherit version;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "explosion-mental";
    repo = "wallust";
    rev = version;
    hash = "sha256-gGyxRdv2I/3TQWrTbUjlJGsaRv4SaNE+4Zo9LMWmxk8=";
  };

  cargoHash = "sha256-dkHS8EOzmn5VLiKP3SMT0ZGAsk2wzvQeioG7NuGGUzA=";

  nativeBuildInputs = [ makeWrapper pkgs.rust-bin.stable."1.77.2".default ];

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
