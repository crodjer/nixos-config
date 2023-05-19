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

      # I use alacritty everywhere
      set -g default-terminal "alacritty"

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

      # Window Navigation
      bind-key -n M-j select-pane -L
      bind-key -n M-k select-pane -D
      bind-key -n M-l select-pane -U
      bind-key -n M-\; select-pane -R

      # Theme
      set -g status-fg white
      set -g status-bg colour8
      set -g status-left '#[fg=black,bg=color15] #S '
      set -g window-status-format "#[fg=white] #I #W:#{s|$HOME|~|;s|/.*/|/…/|:pane_current_path} "
      set -g window-status-current-format "#[fg=black,bg=colour7,bold] #I #W:#{s|$HOME|~|;s|/.*/|/…/|:pane_current_path} "
      set -g status-right '#[fg=black] #{cpu_temp_bg_color}  #{cpu_temp} #{cpu_bg_color}  #{cpu_percentage} #{ram_bg_color}  #{ram_percentage} #[fg=black,bg=color15]  %H:%M '

      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
    plugins = with pkgs.tmuxPlugins; [
      cpu
    ];
  };

}
