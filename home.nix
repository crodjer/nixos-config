{ pkgs, ... }:

let 
  user_name = "rohan";
in {
  imports = [ <home-manager/nixos> ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.${user_name} = {
    home = {
      file = {
        ".config/atuin/config.toml".source = ./configs/atuin.toml;
        ".config/helix".source = ./configs/helix;
        ".config/mako/config".source = ./configs/mako;
        ".config/wofi".source = ./configs/wofi;
      };
      packages = with pkgs; [
        signal-desktop
        pass 
      ];
      stateVersion = "23.11";
    };

    programs = {
      git = {
        enable = true;
        userName = "Rohan Jain";
        userEmail = "crodjer@proton.me";

        signing = {
          key = null;
          signByDefault = true;
        };
      };
    };
  };
}
