{ config, lib, ... }:
let
  cfg = config.profile.audio;
in
{
  config = lib.mkIf cfg.enable {
    # services.pulseaudio.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
