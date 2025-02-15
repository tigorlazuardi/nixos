require("snacks").setup {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true, replace_netrw = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
}

vim.keymap.set("n", "<leader>bd", "<cmd>lua Snacks.bufdelete()<cr>", {
    desc = "Deletes buffer",
})

vim.keymap.set("n", "<leader>bD", "<cmd>lua Snacks.bufdelete.other()<cr>", {
    desc = "Deletes other buffers",
})
