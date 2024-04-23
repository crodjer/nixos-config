# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, ... }:

let 
  user_name = "rohan";
  update-system = pkgs.writeShellScriptBin "update" (builtins.readFile ./scripts/update.sh);
  ping-monitor = pkgs.writeShellScriptBin "ping-monitor" (builtins.readFile ./scripts/ping-monitor.sh);
in {
  # Bootloader.
  boot = {
    initrd.systemd.enable = true;
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
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver intel-ocl
      ];
    };
  };
  powerManagement.enable = true;

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
          commands = [
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = [ "NOPASSWD" ]; 
            }
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
    networkmanager = {
      # Enable networking
      enable = true;
    };
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5000 ];
    };
  };

  zramSwap = {
    enable = true;
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
  users.users.${user_name} = {
    isNormalUser = true;
    description = "Rohan";
    extraGroups = [ "adbusers" "networkmanager" "wheel" "video" "tss" ];
    # packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # Cli utilities
      bat bc bottom dogdns dust entr eza fd fzf git jq ripgrep unzip xdg-utils
      zsh-completions zoxide

      # Applications
      anki-bin mpv
      brave
      gimp
      helix
      imv
      ledger
      neovim-remote
      rbw
      v4l-utils
      vlc
      yazi

      # Tools and Services
      ansible
      gocryptfs

      # Languages
      elixir
      hurl
      gcc
      go
      nodejs_21
      python3
      # Rust
      cargo cargo-generate rustc rust-analyzer

      # Wasm
      trunk lld

      # My custom scripts
      update-system

      # LSP Services and Linters
      ansible-language-server ansible-lint
      elixir-ls
      gopls
      lua-language-server
      nil
      ruff ruff-lsp
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    etc = {
      "xdg/user-dirs.defaults".source = ./configs/user-dirs.dirs;
      "xdg/waybar".source = ./configs/waybar;
      "xdg/wezterm/wezterm.lua".source = ./configs/wezterm.lua;
      "sway/scripts".source = ./configs/sway/scripts;
      "sway/config".source = ./configs/sway/sway.conf;
      "sway/config.d/theme.conf".source = ./configs/sway/theme.conf;
      "swaynag/config".source = ./configs/swaynag;
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
    direnv.enable = true;
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
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
        # We need ESR for this to work.
        SearchEngines = lib.importJSON ./configs/firefox/search.json;
        # DNSOverHTTPS = lib.importJSON ./configs/firefox/dns-over-https.json;
      };
      preferences = {
        "browser.warnOnQuitShortcut" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        # "browser.newtabpage.pinned" = builtins.readFile ./configs/firefox/pinned.json;

        # Remove bloat and sponsored content.
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
            aerial-nvim
            catppuccin-nvim
            gitsigns-nvim
            indent-blankline-nvim
            fidget-nvim
            fzf-lua
            hurl
            lualine-nvim
            nvim-autopairs
            nvim-cmp cmp-nvim-lsp cmp-buffer
            nvim-lspconfig
            nvim-web-devicons
            rust-vim
            statix
            vim-commentary
            vim-nix
            vim-ledger
            ultisnips cmp-nvim-ultisnips

            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                python rust ruby lua bash vim yaml ledger json markdown
                tsx javascript typescript go clojure haskell elixir
              ]
            ))
          ];
        };
      };
    };

    nix-ld.enable = true;
    starship.enable = true;

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        bemenu clipman gammastep glib grim mako ping-monitor swaylock swayidle
        (waybar.override {
          wireplumberSupport = false;
        })
        wayland-utils wezterm wl-clipboard wofi
      ];
      extraSessionCommands = builtins.readFile ./configs/sway/env.sh;
    };

    zsh = {
      enable = true;
      shellInit = ''
        # Preempt the annoying new user prompt.
        if [ ! -e "$HOME/.zshrc" ]; then
          touch $HOME/.zshrc
        fi

        if [ "$USER" = ${user_name} ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec sway
        fi
        '';
        interactiveShellInit = builtins.readFile ./configs/zshrc;
        shellAliases = {
          rebuild = "sudo nixos-rebuild switch";
          clean-os = "sudo bash -c 'nix-collect-garbage --delete-older-than 1d && nixos-rebuild switch'";
          o = "xdg-open";
          nvr = "nvr --remote-silent";
        };
      };
    };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    blueman.enable = true;
    dbus.enable = true;
    flatpak.enable = true;
    fstrim.enable = true;
    geoclue2.enable = true;
    geoclue2.enableDemoAgent = lib.mkForce true;
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
    tlp.enable = true;
    udev = {
      packages = [ pkgs.yubikey-personalization ];
    };
    udisks2 = {
      enable = true;
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 24;
          };
        };
      };
    };
    mime = {
      defaultApplications = builtins.zipAttrsWith
      (_: values: values)
      (let
        subtypes = type: program: subt:
        builtins.listToAttrs (builtins.map
        (x: {name = type + "/" + x; value = program; })
        subt);
      in [
        {
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "application/pdf" = "firefox.desktop";
        }
        (subtypes "image" "imv.desktop"
        [ "png" "jpeg" "jpg" "gif" "svg" "svg+xml" "tiff" "x-tiff" "x-dcraw" ])
      ]);
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
