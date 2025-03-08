{
  programs.nixvim = {
    colorschemes = {
      catppuccin = {
        enable = false;
        settings = {
          transparent_background = true;
          integrations = {
            blink_cmp = true;
            grug_far = true;
            neotest = true;
            noice = true;
            ufo = true;
            snacks = {
              enabled = true;
              indent_scope_color = "lavender";
            };
            lsp_trouble = true;
            dadbod_ui = true;
            which_key = true;
          };
        };
      };
      nord = {
        enable = false;
        settings = {
          borders = false;
          disable_background = true;
        };
      };
      rose-pine = {
        enable = true;
        settings = {
          dark_variant = "main";
          dim_inactive_windows = false;
          extend_background_behind_borders = true;
          styles.transparency = true;
        };
      };
    };
  };
}
