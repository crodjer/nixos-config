# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
  ] ++ lib.optional (builtins.pathExists /etc/nixos/swap.nix) /etc/nixos/swap.nix
    ++ lib.optional (builtins.pathExists /etc/nixos/local.nix) /etc/nixos/local.nix;

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth = {
      enable = true;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
  powerManagement.enable = true;

  security = {
    pam = {
      enableFscrypt = true;
    };
    sudo = {
      extraConfig = ''
        Defaults        timestamp_timeout=30
      '';
    };
  };

  networking = {
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
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # Cli utilities
      bat bottom eza fd fzf git jq rbw

      # Applications
      neovim-remote
      rbw
      signal-desktop
      wezterm

      # Services
      clipman
      dufs
      gammastep
      wl-clipboard
      wofi

      # Languages
      ansible

      # LSP Services and Linters
      ansible-language-server ansible-lint
      lua-language-server
      nodePackages.pyright
      nodePackages.typescript-language-server
      rnix-lsp
      rubyPackages.solargraph
      rust-analyzer
    ];

    etc = {
      "xdg/user-dirs.defaults".source = ./configs/user-dirs.dirs;
      "xdg/waybar".source = ./configs/waybar;
      "xdg/wezterm/wezterm.lua".source = ./configs/wezterm.lua;
      "xdg/wofi".source = ./configs/wofi;
      "sway/scripts".source = ./configs/sway/scripts;
      "sway/config".source = ./configs/sway/sway.conf;
    };

    variables = {
      BAT_THEME = "base16-256";
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  programs = {
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DefaultDownloadDirectory = "\${home}/downloads";
        DisplayBookmarksToolbar = "newtab";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        DNSOverHTTPS = lib.importJSON ./configs/firefox/dns-over-https.json;
        ExtensionSettings = lib.mkForce(lib.importJSON ./configs/firefox/extensions.json);
      };
      preferences = {
        "browser.warnOnQuitShortcut" = false;
        "browser.uiCustomization.state" = builtins.readFile ./configs/firefox/ui-customization.json;
        "browser.newtabpage.pinned" = builtins.readFile ./configs/firefox/pinned.json;

        "browser.newtabpage.activity-stream.discoverystream.newSponsoredLabel.enabled" = false;
        "browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled" = false;
        "browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled" = false;
        "browser.newtabpage.activity-stream.discoverystream.sponsored-collections.enabled" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.urlbar.pocket.featureGate" = false;
        "browser.urlbar.quicksuggest.impressionCaps.sponsoredEnabled" = false;
        "browser.urlbar.sponsoredTopSites" = false;
        "browser.urlbar.suggest.pocket" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "extensions.pocket.bffRecentSaves" = false;
        "extensions.pocket.enabled" = false;
        "extensions.pocket.refresh.emailButton.enabled" = false;
        "extensions.pocket.refresh.hideRecentSaves.enabled" = false;
        "extensions.pocket.showHome" = false;

        # These aren't allowed to be overridden.
        # "services.sync.prefs.sync-seen.browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        # "services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        # "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
        # "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

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

    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = builtins.readFile ./configs/neovim.vim;
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [ 
            ansible-vim
            catppuccin-nvim
            fzf-vim
            gitsigns-nvim
            indent-blankline-nvim
            lualine-nvim
            nvim-autopairs
            nvim-lspconfig
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                python rust ruby lua nix bash vim yaml ledger json
                tsx javascript typescript go clojure haskell
              ]
            ))
            rust-vim
            statix
            vim-commentary
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
        autoload -Uz compinit
        compinit
      '';
      shellAliases = {
        clean-os = "sudo nix-collect-garbage -d";
        rebuild = "sudo nixos-rebuild switch --upgrade";
      };
    };

    starship.enable = true;
    sway.enable = true;
    waybar.enable = true;
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    blueman.enable = true;
    fstrim.enable = true;
    geoclue2.enable = true;
    geoclue2.enableDemoAgent = lib.mkForce true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        };
      };
    };
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
       START_CHARGE_THRESH_BAT0 = 60; # 40 and bellow it starts to charge
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
