{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.keyboard;
in
lib.mkMerge [
  {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.waylandFrontend = true;
    };
  }
  {
    i18n.inputMethod = lib.mkIf cfg.language.japanese ({
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    });
  }
  {
    environment.variables = lib.mkIf (config.i18n.inputMethod.enabled == "fcitx5") {
      # Integration with some tools and binaries like kitty.
      GLFW_IM_MODULE = "ibus";
    };
  }
]
