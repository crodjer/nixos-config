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
      ];
      allowedUDPPorts = [
        # Localsend
        53317
      ];
    };
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
        };
        Network = {
          EnableIPv6 = true;
          NameResolvingService = "systemd";
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };

  zramSwap = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

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
      bat bc bottom dogdns dust entr fd fzf git jq mtpfs pass ripgrep unzip
      xdg-user-dirs xdg-utils zsh-completions zoxide

      ## Applications
      imv
      ledger
      neovim-remote
      rbw
      yazi

      ## Tools and Services
      ansible

      ## Languages
      python3
      # Rust
      cargo cargo-generate rustc rust-analyzer

      # My custom scripts
      update-system

      ## LSP Services and Linters
      ansible-language-server ansible-lint
      lua-language-server
      nil
      ruff ruff-lsp
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    etc = {
      "xdg/user-dirs.defaults".source = ./configs/user-dirs.dirs.default;
      "xdg/foot/foot.ini".source = ./configs/foot.ini;
      "xdg/waybar".source = ./configs/waybar;
      "xdg/wofi".source = ./configs/wofi;
      "xdg/kanshi".source = ./configs/kanshi;
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
      };
      preferences = {
        "browser.warnOnQuitShortcut" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;

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
        bemenu clipman foot glib grim kanshi libnotify mako ping-monitor
        swaylock swayidle
        (waybar.override {
          wireplumberSupport = false;
        })
        wayland-utils wl-clipboard wlsunset wofi
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

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-24.05";
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
