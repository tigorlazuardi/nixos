{
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;
      settings = {
        size.__raw = ''
          function(term)
            if term.direction == "horizontal" then
              return vim.o.lines * 0.3
            end
            return vim.o.columns * 0.3
          end
        '';
        open_mapping.__raw = ''"<F5>"'';
      };
    };
  };
}
