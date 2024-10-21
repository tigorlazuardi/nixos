{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  saveDir = "${config.home.homeDirectory}/Pictures/screenshots";
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
      satty
    ];

    home.activation.sattyDirCreate =
      lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
        ''
          mkdir -p "${saveDir}"
          chown ${config.home.username} "${saveDir}"
        '';

    wayland.windowManager.hyprland.settings.bind =
      let
        filename = "$(date +%Y-%m-%d_%H%M%S).png";
        sattyFilename = "${saveDir}/${filename}";
        sattySaveCommand = ''satty --save-after-copy --filename - --fullscreen --output-filename ${sattyFilename}'';
      in
      [
        "$mod, PRINT, exec, hyprshot -m window --filename ${filename} --output-folder ${saveDir}"
        "$mod SHIFT, PRINT, exec, hyprshot -m window --raw | ${sattySaveCommand}"
        ", PRINT, exec, hyprshot -m region --filename ${filename} --output-folder ${saveDir}"
        "SHIFT, PRINT, exec, hyprshot -m region --raw | ${sattySaveCommand}"
        "ALT, PRINT, exec, hyprshot -m output --filename ${filename} --output-folder ${saveDir}"
        "ALT SHIFT, PRINT, exec, hyprshot -m output --raw | ${sattySaveCommand}"
      ];
  };
}
