{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profile.home.programs.java;
  inherit (lib) mkIf;
  version = "1.18.36";
  lombokJar = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-${version}.jar";
    sha256 = "sha256-c7awW2otNltwC6sI0w+U3p0zZJC8Cszlthgf70jL8Y4=";
  };
in
{
  config = mkIf cfg.enable {
    # This registers lombok jar to the Java classpath
    # https://github.com/NixOS/nixpkgs/blob/689fed12a013f56d4c4d3f612489634267d86529/pkgs/development/libraries/java/lombok/default.nix#L21
    home.packages = [
      pkgs.lombok
      pkgs.jdt-language-server
    ];

    # This one adds the lombok jar to the session variables so programs
    # can find it if they cannot find it in the classpath.
    home.sessionVariables = {
      LOMBOK_JAR = lombokJar;
    };
  };
}
