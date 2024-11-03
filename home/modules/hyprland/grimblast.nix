{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.meta) getExe;
  cfg = config.profile.hyprland;
  saveDir = "${config.home.homeDirectory}/Pictures/screenshots";
  grimblast = inputs.hyprland-contrib.packages.${pkgs.system}.grimblast;
  script =
    mode:
    pkgs.writeShellScriptBin "grimblast-${mode}.sh" ''
      mkdir -p "${saveDir}/original" "${saveDir}/edit"

      file=$(date +%Y-%m-%d_%H%M%S).png
      filename=${saveDir}/original/$file
      ${grimblast}/bin/grimblast save ${mode} "$filename"
      action=$(notify-send --icon="$filename" --app-name="grimblast" --action="copy=Copy" --action="edit=Edit" --action="delete=Delete" "Grimblast" "Screenshot saved to $filename")
      case $action in
          "copy")
              wl-copy < "$filename"
              notify-send --icon="$filename" --app-name="grimblast" "Grimblast" "Screenshot copied to clipboard"
              ;;
          "edit")
              satty --save-after-copy --filename "$filename" --fullscreen --output-filename "${saveDir}/edit/$(date +%Y-%m-%d_%H%M%S).png"
              ;;
          "delete")
              rm "$filename"
              notify-send --app-name="grimblast" "Grimblast" "Screenshot $filename deleted"
              ;;
      esac
    '';
  saveAreaScript = script "area";
  saveOutputScript = script "output";
in
{
  config = mkIf cfg.enable {
    home.packages = [
      grimblast
      pkgs.satty
      pkgs.libnotify
    ];

    wayland.windowManager.hyprland.settings.bind = [
      ", PRINT, exec, ${getExe saveAreaScript}"
      "$mod, PRINT, exec, ${getExe saveOutputScript}"
    ];
  };
}
