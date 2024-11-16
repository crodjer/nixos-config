{ pkgs, ... }:

{
  networking.hostName = "sirius";

  environment = {
    etc = {
      "sway/config.d/monitor.conf".source = ../configs/sway/monitor.conf;
    };

    systemPackages = with pkgs; [
      audacity
      anki-bin
      mpv
      gimp
      gocryptfs
      google-chrome
      localsend
      piper
      signal-desktop
      v4l-utils
      vlc
      whatsapp-for-linux
      yt-dlp 
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

  services.ratbagd.enable = true;
}
