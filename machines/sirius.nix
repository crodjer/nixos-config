{ pkgs, ... }:

{
  networking.hostName = "sirius";

  environment = {
    etc = {
      "sway/config.d/monitor.conf".source = ../configs/sway/monitor.conf;
    };
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
    services.charge-limit = {
      script = builtins.readFile ../scripts/charge-limit.sh;
    };

    services.prevent-overcharge = {
      # Ensure that the system doesn't over charge when plugged in and suspended
      # / turned off.
      wantedBy = [ "sleep.target" "shutdown.target" ];
      script = ''
        ${pkgs.tlp}/bin/tlp setcharge 0 1
      '';
    };
  };
}
