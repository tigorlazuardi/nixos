{ unstable, ... }:
{
  programs.nixvim.plugins.noice = {
    enable = true;
    package = unstable.vimPlugins.noice-nvim;
    lazyLoad.settings.event = [ "DeferredUIEnter" ];
    settings = {
      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };
      lsp.progress.enabled = false;
      hover.silent = true;
      notify.view = "mini";
      presets = {
        lsp_doc_border = true;
        bottom_search = true;
        command_pallete = true;
        long_message_to_split = true;
        inc_rename = false;
      };
    };
  };
}
