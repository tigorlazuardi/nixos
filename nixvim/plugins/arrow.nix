{
  programs.nixvim.plugins.arrow = {
    enable = false;
    settings = {
      show_icons = true;
      leader_key = "<cr>";
    };
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "<cr>";
        desc = "Open Arrow Bookmarks";
      }
    ];
  };
}
