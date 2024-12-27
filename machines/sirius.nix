{ pkgs, ... }:
let
  ping-monitor = pkgs.writeShellScriptBin "ping-monitor" (builtins.readFile ./scripts/ping-monitor.sh);
in {
  networking.hostName = "sirius";

  environment = {
    etc = {
      "xdg/foot/foot.ini".source = ./configs/foot.ini;
      "xdg/waybar".source = ./configs/waybar;
      "xdg/wezterm/wezterm.lua".source = ./configs/wezterm.lua;
      "sway/scripts".source = ./configs/sway/scripts;
      "sway/config".source = ./configs/sway/sway.conf;
      "sway/config.d/theme.conf".source = ./configs/sway/theme.conf;
      "sway/wofi".source = ./configs/wofi;
      "sway/shikane".source = ./configs/shikane;
      "sway/swayidle".source = ./configs/swayidle;
      "swaynag/config".source = ./configs/swaynag;
    };

    systemPackages = with pkgs; [
      gimp
      gocryptfs
      inkscape
      localsend
      ollama
      piper
      pipx
      podman-compose

      # Rust
      rustup cargo-binstall cargo-update

      signal-desktop
      taskwarrior3 tasksh taskwarrior-tui timewarrior
      tty-clock
      v4l-utils
      vlc
    ];
  };

  systemd = {
    timers.charge-limit = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "0";
        OnUnitActiveSec = "1m";
        Unit = "charge-limit.service";
      };
    };
    services = {
      charge-limit = {
        script = builtins.readFile ../scripts/charge-limit.sh;
      };
      prevent-overcharge = {
        # Ensure that the system doesn't over charge when plugged in and suspended
        # / turned off.
        wantedBy = [ "sleep.target" "shutdown.target" ];
        script = ''
          ${pkgs.tlp}/bin/tlp setcharge 0 1
        '';
      };
      rfkill-unblock = {
        after = [ "resume.target" ];
        wantedBy = [ "multi-user.target" "resume.target" ];
        script = "${pkgs.util-linux}/bin/rfkill unblock all";
      };
    };

  };

  services = {
    ratbagd.enable = true;
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    xdg = {
      portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
        wlr = {
          enable = true;
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

  };

  programs = {
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

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        bemenu clipman foot glib grim libnotify mako ping-monitor
        shikane swaylock swayidle
        (waybar.override {
          wireplumberSupport = false;
        })
        wayland-utils wl-clipboard wlsunset wofi
      ];
      extraSessionCommands = builtins.readFile ./configs/sway/env.sh;
    };
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };
}
