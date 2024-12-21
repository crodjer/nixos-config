{ pkgs, ... }:

{
  networking.hostName = "sirius";

  environment = {
    etc = {
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
      signal-desktop
      taskwarrior3 tasksh taskwarrior-tui timewarrior
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

  services.ratbagd.enable = true;

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };
}
