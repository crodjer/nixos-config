# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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
  environment.systemPackages = with pkgs; [
    ansible
    ansible-lint
    bat
    bottom
    eza
    fd
    fzf
    git
    jq
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = ''
          colorscheme default
          set termguicolors
          set colorcolumn=+1

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
      settings = {
        default-cache-ttl = 60480000;
      };
    };

    starship = {
      enable = true;
      settings = {
      };
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
