{ plugins, ... }:
/*kdl*/ ''
  layout {
      pane split_direction="vertical" {
          pane
      }

      pane size=1 borderless=true {
          plugin location="file:${plugins.zj-status}" {
              // -- Catppuccin Frappé --
              color_rosewater "#f2d5cf"
              color_flamingo "#eebebe"
              color_pink "#f4b8e4"
              color_mauve "#ca9ee6"
              color_red "#e78284"
              color_maroon "#ea999c"
              color_peach "#ef9f76"
              color_yellow "#e5c890"
              color_green "#a6d189"
              color_teal "#81c8be"
              color_sky "#99d1db"
              color_sapphire "#85c1dc"
              color_blue "#8caaee"
              color_lavender "#babbf1"
              color_text "#c6d0f5"
              color_subtext1 "#b5bfe2"
              color_subtext0 "#a5adce"
              color_overlay2 "#949cbb"
              color_overlay1 "#838ba7"
              color_overlay0 "#737994"
              color_surface2 "#626880"
              color_surface1 "#51576d"
              color_surface0 "#414559"
              color_base "#303446"
              color_mantle "#292c3c"
              color_crust "#232634"

              format_left   "#[bg=$surface0,fg=$sapphire]#[bg=$sapphire,fg=$crust,bold] {session} #[bg=$surface0] {mode}#[bg=$surface0] {tabs}"
              format_center "{notifications}"
              format_right  "#[bg=$surface0,fg=$flamingo]#[fg=$crust,bg=$flamingo] #[bg=$surface1,fg=$flamingo,bold] {command_user}@{command_host}#[bg=$surface0,fg=$surface1]#[bg=$surface0,fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$maroon,bold] {datetime}#[bg=$surface0,fg=$surface1]"
              format_space  "#[bg=$surface0]"
              format_hide_on_overlength "true"
              format_precedence "lrc"

              border_enabled  "false"
              border_char     "─"
              border_format   "#[bg=$surface0]{char}"
              border_position "top"

              hide_frame_for_single_pane "true"

              mode_normal        "#[bg=$green,fg=$crust,bold] NORMAL#[bg=$surface0,fg=$green]"
              mode_tmux          "#[bg=$mauve,fg=$crust,bold] TMUX#[bg=$surface0,fg=$mauve]"
              mode_locked        "#[bg=$red,fg=$crust,bold] LOCKED#[bg=$surface0,fg=$red]"
              mode_pane          "#[bg=$teal,fg=$crust,bold] PANE#[bg=$surface0,fg=teal]"
              mode_tab           "#[bg=$teal,fg=$crust,bold] TAB#[bg=$surface0,fg=$teal]"
              mode_scroll        "#[bg=$flamingo,fg=$crust,bold] SCROLL#[bg=$surface0,fg=$flamingo]"
              mode_enter_search  "#[bg=$flamingo,fg=$crust,bold] ENT-SEARCH#[bg=$surfaco,fg=$flamingo]"
              mode_search        "#[bg=$flamingo,fg=$crust,bold] SEARCHARCH#[bg=$surfac0,fg=$flamingo]"
              mode_resize        "#[bg=$yellow,fg=$crust,bold] RESIZE#[bg=$surfac0,fg=$yellow]"
              mode_rename_tab    "#[bg=$yellow,fg=$crust,bold] RENAME-TAB#[bg=$surface0,fg=$yellow]"
              mode_rename_pane   "#[bg=$yellow,fg=$crust,bold] RENAME-PANE#[bg=$surface0,fg=$yellow]"
              mode_move          "#[bg=$yellow,fg=$crust,bold] MOVE#[bg=$surface0,fg=$yellow]"
              mode_session       "#[bg=$pink,fg=$crust,bold] SESSION#[bg=$surface0,fg=$pink]"
              mode_prompt        "#[bg=$pink,fg=$crust,bold] PROMPT#[bg=$surface0,fg=$pink]"

              tab_normal              "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
              tab_normal_fullscreen   "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
              tab_normal_sync         "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
              tab_active              "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
              tab_active_fullscreen   "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
              tab_active_sync         "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
              tab_separator           "#[bg=$surface0] "

              tab_sync_indicator       " "
              tab_fullscreen_indicator " 󰊓"
              tab_floating_indicator   " 󰹙"

              notification_format_unread "#[bg=surface0,fg=$yellow]#[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[bg=$surface0,fg=$yellow]"
              notification_format_no_notifications ""
              notification_show_interval "10"

              command_host_command    "uname -n"
              command_host_format     "{stdout}"
              command_host_interval   "0"
              command_host_rendermode "static"

              command_user_command    "whoami"
              command_user_format     "{stdout}"
              command_user_interval   "10"
              command_user_rendermode "static"

              datetime          "{format}"
              datetime_format   "%Y-%m-%d 󰅐 %H:%M"
              datetime_timezone "Europe/Stockholm"
          }
      }
  }
''
