# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ] ++ lib.optional
         (builtins.pathExists /etc/nixos/swap.nix)
         /etc/nixos/swap.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      # Enable networking
      enable = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5000 ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rohan = {
    isNormalUser = true;
    description = "Rohan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      ansible
      ansible-lint
      bat
      bottom
      clipman
      dufs
      eza
      fd
      firefox
      wezterm
      fzf
      gammastep
      geoclue2-with-demo-agent
      git
      jq
      wofi
    ];

    etc = {
      "sway/config".source = ./configs/sway.conf;
      "xdg/waybar".source = ./configs/waybar;
      "wezterm/wezterm.lua".source = ./configs/wezterm.lua;
    };

    variables = {
      WEZTERM_CONFIG_FILE = "/etc/wezterm/wezterm.lua";
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = ''
          set background=light
          set termguicolors
          set colorcolumn=+1
          colorscheme catppuccin

          set expandtab tabstop=2 softtabstop=2 shiftwidth=2
          set showcmd wildmenu wildmode=full:lastused wildoptions=fuzzy
          set wildignore=*.o,*~,*.pyc,*.hi,*.class
          set relativenumber number showmode laststatus=2

          let mapleader = ','

          nnoremap <leader>s :GFiles<CR>
          nnoremap <leader>f :Files<CR>
          nnoremap <leader>b :Buffers<CR>
          nnoremap <leader>h :History<CR>
          nnoremap <leader>c :Command<CR>

          :cnoremap <C-A> <Home>
          :cnoremap <C-F> <Right>
          :cnoremap <C-B> <Left>
          :cnoremap <Esc>b <S-Left>
          :cnoremap <Esc>f <S-Right>
        '';
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [ 
            ale
            ansible-vim
            fzf-vim
            catppuccin-nvim
            rust-vim
            statix
            vim-nix
            vim-ledger
          ];
        };
      };
    };

    zsh = {
      enable = true;
      shellInit = ''
        # Preempt the annoying new user prompt.
        if [ ! -e "$HOME/.zshrc" ]; then
          touch $HOME/.zshrc
        fi
      '';
      interactiveShellInit = ''
        bindkey -e
        HISTFILE=~/.histfile
        HISTSIZE=10000
        SAVEHIST=100000
        setopt autocd beep extendedglob nomatch notify
        zstyle :compinstall filename '/home/rohan/.zshrc'
        autoload -Uz compinit
        compinit
      '';
      shellAliases = {
        clean-os = "sudo nix-collect-garbage -d";
        rebuild = "sudo nixos-rebuild switch --upgrade";
      };
    };

    git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
        user = {
          name = "Rohan Jain";
          email = "crodjer@proton.me";
        };
        commit = {
          verbose = true;
        };
        rerere = {
          enabled = true;
        };
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl = 60480000;
      };
    };

    light.enable = true;
    starship.enable = true;
    sway.enable = true;
    waybar.enable = true;
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        };
      };
    };
    blueman = {
      enable = true;
    };
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

       #Optional helps save long term battery health
       START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
       STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

     };
   };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
