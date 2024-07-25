{ config, lib, ... }:
let
  cfg = config.profile.home.programs.zellij;
in
{
  config = lib.mkIf cfg.enable {
    programs.zellij.enable = true;

    programs.zsh.initExtraFirst = lib.mkOrder 20000 (
      /*bash*/ ''
      ZELLIJ_AUTO_EXIT=true
      ZELLIJ_AUTO_ATTACH=${toString cfg.autoAttach}
      eval "$(zellij setup --generate-auto-start zsh)"
    ''
    );

    home.file.".config/zellij/config.kdl".text = /*kdl*/ ''
      theme "catppuccin-mocha";

      keybinds clear-defaults=true {
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
            bind "s" { SwitchToMode "Session"; }
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
            bind "s" {
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
  };
}
