{
  programs.nixvim.extraConfigLua = ''
    if vim.g.neovide then
      local font = "JetBrainsMono Nerd Font"

      local font_size = vim.o.lines < 60 and 11 or 12

      vim.o.guifont = font .. ":h" .. font_size
      vim.g.neovide_opacity = 0.7
      vim.g.transparency = 0.8
      vim.g.neovide_window_blurred = true

      vim.keymap.set("n", "<c-->", function()
        font_size = font_size - 1
        vim.o.guifont = font .. ":h" .. font_size
        vim.notify("Font Set: " .. font .. ":h" .. font_size)
      end, { desc = "Decrease font size" })

      vim.keymap.set("n", "<c-=>", function()
        font_size = font_size + 1
        vim.o.guifont = font .. ":h" .. font_size
        vim.notify("Font Set: " .. font .. ":h" .. font_size)
      end, { desc = "Increase font size" })
    end
  '';
}
