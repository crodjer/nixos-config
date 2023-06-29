{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "s";
    escapeTime = 0;
    extraConfig = ''
      # Automatically set window title
      set-window-option -g automatic-rename on
      set-window-option -g main-pane-width 100
      set -g pane-active-border-style fg=color196,bg=default

      # Emacs key bindings in tmux command prompt (prefix + :) are better than
      # vi keys, even for vim users
      set -g status-keys emacs

      set-option -g set-titles on
      set-option -g mouse on

      set -g default-terminal "$TERM"

      ## Copy mode
      # Use vim keybindings in copy mode
      setw -g mode-keys vi

      # Setup 'v' to begin selection as in Vim
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection

      # Window Management
      unbind-key -n M-f
      bind-key -n M-\' split-window -v
      bind-key -n M-\\ split-window -h
      bind-key -n M-F resize-pane -Z
      bind-key z last-window
      bind-key -n M-z last-window

      # Select windows by number
      bind -n M-0 select-window -t 0
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Window Navigation
      bind-key -n M-j select-pane -L
      bind-key -n M-k select-pane -D
      bind-key -n M-l select-pane -U
      bind-key -n M-\; select-pane -R

      # Theme
      set -g status-fg white
      set -g status-bg black

      set -g window-status-current-style 'fg=black,bg=brightyellow,bold'
      set -g window-status-bell-style 'fg=black,bg=red,blink'
      set -g window-status-separator ""
      # Substitue Home Directory with ~ and any nested paths with …/
      # Also, substitute zsh and bash shells with $
      set -g window-status-format " #I #{s|zsh|$|;s|bash|$|:pane_current_command}:#{s|$HOME|~|;s|/.*/|…/|:pane_current_path} "
      set -Fg window-status-current-format "#{window-status-format}"
      set -g status-left "#[fg=black,bg=brightyellow] #S "
      set -g status-right "#[fg=black]#{cpu_bg_color} C:#{cpu_percentage} #{ram_bg_color} M:#{ram_percentage}  #[bg=brightyellow] %H:%e"

      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
    plugins = with pkgs.tmuxPlugins; [
      cpu
    ];
  };

}
