{ plugins, timezone, ... }:
# kdl
''
  layout {
      pane split_direction="vertical" {
          pane
      }

      pane size=1 borderless=true {
          plugin location="file:${plugins.zj-status}" {
              // -- Catppuccin Latte --
              color_rosewater "#dc8a78"
              color_flamingo "#dd7878"
              color_pink "#ea76cb"
              color_mauve "#8839ef"
              color_red "#d20f39"
              color_maroon "#e64553"
              color_peach "#fe640b"
              color_yellow "#df8e1d"
              color_green "#40a02b"
              color_teal "#179299"
              color_sky "#04a5e5"
              color_sapphire "#209fb5"
              color_blue "#1e66f5"
              color_lavender "#7287fd"
              color_text "#4c4f69"
              color_subtext1 "#5c5f77"
              color_subtext0 "#6c6f85"
              color_overlay2 "#7c7f93"
              color_overlay1 "#8c8fa1"
              color_overlay0 "#9ca0b0"
              color_surface2 "#acb0be"
              color_surface1 "#bcc0cc"
              color_surface0 "#ccd0da"
              color_base "#eff1f5"
              color_mantle "#e6e9ef"
              color_crust "#dce0e8"

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

              hide_frame_for_single_pane "false"

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
              datetime_timezone "${timezone}"
          }
      }
  }
''
