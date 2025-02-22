{ unstable, ... }: {
  programs.nixvim = {
    extraPackages = with unstable; [ lua-language-server ];

    plugins = {
      lazydev = {
        enable = true;
        lazyLoad.settings.ft = [ "lua" ];
      };
      blink-cmp.settings.sources = {
        default = [ "lazydev" ];
        providers = {
          lazydev = {
            name = "LazyDev";
            module = "lazydev.integrations.blink";
            # make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100;
          };
        };
      };
    };
  };
}
