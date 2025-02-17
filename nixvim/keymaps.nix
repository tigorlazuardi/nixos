[
  {
    action = "<gv";
    key = "<";
    mode = "v";
    options.desc = "Indent Left";
  }
  {
    action = ">gv";
    key = ">";
    mode = "v";
    options.desc = "Indent Right";
  }
  # Add undo breakpoints on typing , . ;
  {
    key = ",";
    action = ",<c-g>U";
    mode = "i";
  }
  {
    key = ".";
    action = ".<c-g>U";
    mode = "i";
  }
  {
    key = ";";
    action = ";<c-g>U";
    mode = "i";
  }
  {
    key = "<esc>";
    action.__raw = ''
      function()
        vim.cmd("noh")
        return "<esc>"
      end
    '';
    mode = [
      "i"
      "n"
      "s"
    ];
    options = {
      expr = true;
      desc = "Escape and Clear HLSearch";
    };
  }

  # Better moving up / down
  {
    key = "j";
    action = "v:count == 0 ? 'gj' : 'j'";
    mode = [
      "n"
      "x"
    ];
    options = {
      desc = "Down";
      expr = true;
      silent = true;
    };
  }
  {
    key = "<Down>";
    action = "v:count == 0 ? 'gj' : 'j'";
    mode = [
      "n"
      "x"
    ];
    options = {
      desc = "Down";
      expr = true;
      silent = true;
    };
  }
  {
    key = "k";
    action = "v:count == 0 ? 'gk' : 'k'";
    mode = [
      "n"
      "x"
    ];
    options = {
      desc = "Up";
      expr = true;
      silent = true;
    };
  }
  {
    key = "<Up>";
    action = "v:count == 0 ? 'gk' : 'k'";
    mode = [
      "n"
      "x"
    ];
    options = {
      desc = "Up";
      expr = true;
      silent = true;
    };
  }
]
