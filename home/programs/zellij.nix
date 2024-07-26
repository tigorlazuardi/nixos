{ config, lib, pkgs, ... }:
let
  cfg = config.profile.home.programs.zellij;
  plugins = {
    zj-quit = pkgs.fetchurl {
      url = "https://github.com/cristiand391/zj-quit/releases/download/0.3.0/zj-quit.wasm";
      hash = "sha256-f1D3cDuLRZ5IqY3IGq6UYSEu1VK54TwmkmwWaxVQD2A=";
    };
    zstatus = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.17.0/zjstatus.wasm";
      hash = "sha256-IgTfSl24Eap+0zhfiwTvmdVy/dryPxfEF7LhVNVXe+U";
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.zellij.enable = true;

    # Uses initExtraFirst instead of initExtra
    # to avoid loading of zsh plugins before zellij loads.
    #
    # Let zsh inside zellij that loads zsh plugins.
    #
    # The lib.mkOrder is used to ensure zellij is
    # autoloaded first after zshenv.
    programs.zsh.initExtraFirst = lib.mkOrder 50 (
      /*bash*/ ''
      ZELLIJ_AUTO_EXIT=true
      ZELLIJ_AUTO_ATTACH=${lib.boolToString cfg.autoAttach}
      if [[ -z "$ZELLIJ" ]]; then
          ZJ_SESSIONS=$(zellij list-sessions --no-formatting)
          NO_SESSIONS=$(echo "$ZJ_SESSIONS" | wc -l)
          if [ "$NO_SESSIONS" -ge 2 ]; then
              SELECTED_SESSION=$(echo "$ZJ_SESSIONS" | ${pkgs.skim}/bin/sk | awk '{print $1}')
              if [[ -n "''${SELECTED_SESSION// /}" ]]; then
                  zellij attach -c "$SELECTED_SESSION"
              else
                  zellij attach -c --index 0
              fi
          else
              zellij attach -c
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
              exit
          fi
      fi
    ''
    );

    home.file.".config/zellij/config.kdl".text = /*kdl*/ ''
      theme "catppuccin-mocha";

      plugins {
          zj-quit location="file:${plugins.zj-quit}";
      }

      keybinds clear-defaults=true {
        shared_except "locked" {
            bind "Ctrl q" {
                LaunchOrFocusPlugin "zj-quit" {
                    floating true
                };
            }
        }

        normal {
            bind "Ctrl a" { SwitchToMode "tmux"; }
        }

        locked {
            bind "Ctrl a" { SwitchToMode "normal"; }
        }

        tmux {
            // Switching modes
            bind "Ctrl a" "Ctrl c" "Esc" { SwitchToMode "Normal"; }
            bind "w" { SwitchToMode "Resize"; }
            bind "e" { SwitchToMode "Scroll"; }
            bind "S" { SwitchToMode "Session"; }
            bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
            bind "R" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "\\" { SwitchToMode "locked"; }


            // Pane management
            bind "Enter" { NewPane "Right"; SwitchToMode "Normal"; };
            bind "Backspace" { NewPane "Down"; SwitchToMode "Normal"; };
            bind "q" { CloseFocus; SwitchToMode "Normal"; }
            bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
            bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
            bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
            bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
            bind "H" { MovePane "Left"; SwitchToMode "Normal"; }
            bind "J" { MovePane "Down"; SwitchToMode "Normal"; }
            bind "K" { MovePane "Up"; SwitchToMode "Normal"; }
            bind "L" { MovePane "Right"; SwitchToMode "Normal"; }
            bind "Space" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

            // Tab management
            bind "t" { NewTab; SwitchToMode "Normal"; }
            bind "x" { CloseTab; SwitchToMode "Normal"; }
            bind "1" { GoToTab 1; SwitchToMode "Normal"; }
            bind "2" { GoToTab 2; SwitchToMode "Normal"; }
            bind "3" { GoToTab 3; SwitchToMode "Normal"; }
            bind "4" { GoToTab 4; SwitchToMode "Normal"; }
            bind "5" { GoToTab 5; SwitchToMode "Normal"; }
            bind "6" { GoToTab 6; SwitchToMode "Normal"; }
            bind "7" { GoToTab 7; SwitchToMode "Normal"; }
            bind "8" { GoToTab 8; SwitchToMode "Normal"; }
            bind "9" { GoToTab 9; SwitchToMode "Normal"; }

            // Session management
            bind "s" {
                LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                };
                SwitchToMode "Normal";
            }
        }

        resize {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
            bind "h" "Left" { Resize "Increase Left"; }
            bind "j" "Down" { Resize "Increase Down"; }
            bind "k" "Up" { Resize "Increase Up"; }
            bind "l" "Right" { Resize "Increase Right"; }
            bind "H" { Resize "Decrease Left"; }
            bind "J" { Resize "Decrease Down"; }
            bind "K" { Resize "Decrease Up"; }
            bind "L" { Resize "Decrease Right"; }
            bind "=" "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
        }

        search {
            bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "Ctrl s" { SwitchToMode "Normal"; }
            bind "Ctrl c" "Esc" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            bind "n" { Search "down"; }
            bind "p" { Search "up"; }
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "w" { SearchToggleOption "Wrap"; }
            bind "o" { SearchToggleOption "WholeWord"; }
        }

        entersearch {
            bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
            bind "Enter" { SwitchToMode "Search"; }
        }

        scroll {
            bind "Esc" { SwitchToMode "Normal"; }
            bind "e" { EditScrollback; SwitchToMode "Normal"; }
            bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
        }

        session {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
            bind "d" { Detach; }
            bind "S" {
                LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                };
                SwitchToMode "Normal"
            }
            bind "c" {
                LaunchOrFocusPlugin "configuration" {
                    floating true
                    move_to_focused_tab true
                };
                SwitchToMode "Normal"
            }
        }

        renametab {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
            // bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
        }
        renamepane {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
            // bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        }

        // Unused modes is only given escape keys to return to normal mode.
        pane {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
        }

        move {
            bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
        }
      }
    '';

    home.file.".config/zellij/layouts/default.kdl".text = /*kdl*/ ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="file:${plugins.zstatus}" {
                      format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                      format_center "{tabs}"
                      format_right  "{command_git_branch} {datetime}"
                      format_space  ""

                      border_enabled  "false"
                      border_char     "─"
                      border_format   "#[fg=#6C7086]{char}"
                      border_position "top"

                      hide_frame_for_single_pane "true"

                      mode_normal  "#[bg=blue] "
                      mode_tmux    "#[bg=#ffc387] "

                      tab_normal   "#[fg=#6C7086] {name} "
                      tab_active   "#[fg=#9399B2,bold,italic] {name} "

                      command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                      command_git_branch_format      "#[fg=blue] {stdout} "
                      command_git_branch_interval    "10"
                      command_git_branch_rendermode  "static"

                      datetime        "#[fg=#6C7086,bold] {format} "
                      datetime_format "%A, %d %b %Y %H:%M"
                      datetime_timezone "Europe/Berlin"
                  }
              }
          }
      }
    '';
  };
}
