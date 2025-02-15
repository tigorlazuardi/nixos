{
  # https://www.lazyvim.org/configuration/general
  autowrite = true;
  clipboard.__raw = # lua
    ''
      vim.env.SSH_TTY and "" or "unnamedplus"
    '';
  conceallevel = 2;
  confirm = true;
  cursorline = true;
  expandtab = true;
  fillchars = {
    foldopen = "";
    foldclose = "";
    fold = " ";
    foldsep = " ";
    diff = "╱";
    eob = " ";
  };
  formatoptions = "jcroqlnt";
  grepformat = "%f:%l:%c:%m";
  grepprg = "rg --vimgrep";
  ignorecase = true;
  inccommand = "nosplit";
  jumpoptions = "view";
  laststatus = 3;
  linebreak = true;
  list = true;
  mouse = "a";
  number = true;
  pumblend = 10;
  pumheight = 10;
  relativenumber = true;
  scrolloff = 5;
  sessionoptions = [
    "buffers"
    "curdir"
    "tabpages"
    "winsize"
    "help"
    "globals"
    "skiprtp"
    "folds"
  ];
  shiftround = true;
  shiftwidth = 2;
  shortmess = "ltToOCF" + "WIc";
  showmode = false;
  sidescrolloff = 8;
  signcolumn = "yes";
  smartcase = true;
  smartindent = true;
  spelllang = [ "en" ];
  splitbelow = true;
  splitkeep = "screen";
  splitright = true;
  tabstop = 2;
  termguicolors = true;
  timeoutlen.__raw = # lua
    ''
      vim.g.vscode and 1000 or 300
    '';
  undofile = true;
  undolevels = 10000;
  updatetime = 200;
  virtualedit = "block";
  wildmode = "longest:full,full";
  winminwidth = 5;
  wrap = true;

  smoothscroll = true;
}
