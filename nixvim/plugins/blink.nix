{
  ...
}:
{
  programs.nixvim = {
    plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          ghost_text.enabled = false;
          documentation.window.border = "rounded";
          menu = {
            border = "rounded";
            draw = {
              columns = [
                [ "kind_icon" ]
                [
                  "label"
                  "label_description"
                ]
                [ "kind" ]
              ];
              components = {

              };
            };
          };
        };
        lazyLoad.settings = {
          event = [ "InsertEnter" ];
        };
      };
    };
  };
}
