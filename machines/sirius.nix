{
  networking.hostName = "sirius";

  environment = {
    etc = {
      "sway/config.d/monitor.conf".source = ../configs/sway/monitor.conf;
    };
  };

  services = {
  };
}
