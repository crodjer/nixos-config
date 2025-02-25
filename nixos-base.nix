# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  user_name = "rohan";
  update-system = pkgs.writeShellScriptBin "update" (builtins.readFile ./scripts/update.sh);
in {
  # Bootloader.
  boot = {
    initrd.systemd = {
      enable = true;
      network.wait-online.enable = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "ecryptfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver intel-ocl
      ];
    };
  };
  powerManagement.enable = true;

  console = {
    keyMap = "emacs";
  };

  security = {
    pam = {
      enableEcryptfs = true;
      services = {
        swaylock.u2fAuth = true;
        sudo.u2fAuth = true;
      };
    };
    sudo = {
      extraRules = [
        {
          groups = [ "wheel" ];
          commands = map
            (cmd: {
              command = "/run/current-system/sw/bin/${cmd}";
              options = [ "NOPASSWD" ];
            })
            [
              "nixos-rebuild"
              "nix-collect-garbage"
              "dmesg"
            ];
        }
      ];
      extraConfig = ''
        Defaults        timestamp_timeout=30
      '';
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  networking = {
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        # To spawn temporary servers.
        5000
        # Localsend
        53317
        # Syncthing
        22000
      ];
      allowedUDPPorts = [
        # Localsend
        53317
        # Syncthing
        22000
        21027
      ];
    };

    wireless = {
      enable = true;
      # Run:
      # wpa_passphrase SSID psk | sudo tee /etc/wpa_supplicant.conf
      # to generate a valid wpa supplicant configuration.
    };
  };

  zramSwap = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_IN/UTF-8";
    supportedLocales = [
      "en_IN/UTF-8"
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    extraLocaleSettings = {
      LANG="en_IN.UTF-8";
      LC_ALL = "en_IN.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
    };

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user_name} = {
    isNormalUser = true;
    description = "Rohan";
    extraGroups = [ "adbusers" "networkmanager" "wheel" "video" "tss" ];
    # packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      ## Cli utilities
      bat bc bottom dogdns dust entr fd fzf git jq mosh pass ripgrep stow unzip
      xdg-user-dirs xdg-utils zsh-completions zoxide

      ## Applications
      imv
      neovim-remote
      yazi

      ## Tools and Services
      ansible

      ## Languages
      gcc
      python3

      # My custom scripts
      update-system

      ## LSP Services and Linters
      ansible-language-server ansible-lint lua-language-server nil
      ruff ruff-lsp
    ];

    etc = {
      "xdg/user-dirs.defaults".source = ./configs/user-dirs.dirs.default;
    };

    variables = {
      PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  programs = {
    adb.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl = 60480000;
      };
    };

    light.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = builtins.readFile ./configs/neovim.vim;
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [
            catppuccin-nvim
            fzf-lua

            mini-align
            mini-bracketed
            mini-comment
            mini-completion
            mini-cursorword
            mini-indentscope
            mini-move
            mini-notify
            mini-pairs
            mini-statusline
            mini-surround
            mini-trailspace

            neorg
            nvim-lspconfig
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                bash c clojure css csv desktop elixir erlang fish go haskell
                javascript lua markdown nix python ruby rust scss sql tsv tsx
                typescript vim

                git_config gitattributes gitcommit gitignore glimmer html hurl
                jq json ledger norg ssh_config sway terraform tmux toml xml yaml
                yuck
              ]
            ))
            plenary-nvim
          ];
        };
      };
    };

    nix-ld.enable = true;

    starship.enable = true;

    skim = {
      keybindings = true;
      fuzzyCompletion = true;
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "s";
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        power-theme
        resurrect
      ];
      extraConfigBeforePlugins = builtins.readFile ./configs/tmux.conf;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellInit = ''
        if [ -e "$HOME/.zshrc.local" ]; then
          source "$HOME/.zshrc.local"
        fi
      '';

      interactiveShellInit = builtins.readFile ./configs/zshrc;
      histSize = 100000;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch";
        clean-os = "sudo bash -c 'nix-collect-garbage --delete-older-than 1d && nixos-rebuild switch'";
        addr = "ip -br -c addr";
        o = "xdg-open";
        nvr = "nvr -s --remote-silent";
        t = "task";
        c = "timew";
      };
    };
  };


  # List services that you want to enable:

  services = {
    blueman.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
    logind = {
      powerKey = "suspend";
      extraConfig = ''
      IdleAction=suspend
      IdleActionSec=600
      '';
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      pulse.enable = true;
    };
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
    };
    syncthing = {
      enable = true;
      user = "${user_name}";
      dataDir = "/home/${user_name}";
    };
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        SOUND_POWER_SAVE_ON_AC = 0;
      };
    };
    udev = {
      packages = [ pkgs.yubikey-personalization ];
    };
    udisks2 = {
      enable = true;
    };
  };

  systemd = {
    network = {
      enable = true;
      networks = {
        "10-ethernet" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "yes";
        };
      };
      wait-online.enable = false;
    };
  };

  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = ''
    # Preempt the annoying new user prompt.
    if [ ! -e "$HOME/.zshrc" ]; then
      touch $HOME/.zshrc
    fi
  '';

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-24.11";
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
