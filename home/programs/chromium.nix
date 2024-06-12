{ config, lib, ... }:
let
  cfg = config.profile.chromium;
in
{
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        { id = "jinjaccalgkegednnccohejagnlnfdag"; } # violent monkey
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsor block
        { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; } # privacy badger
        { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # cookie auto delete
        { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Integration
      ];
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };
  };
}
