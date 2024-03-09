{ pkgs, ... }:

let 
  user_name = "rohan";
in {
  imports = [ <home-manager/nixos> ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.${user_name} = {
    home = {
      file = {
        ".config/helix".source = ./configs/helix;
        ".config/mako/config".source = ./configs/mako;
        ".config/wofi".source = ./configs/wofi;
        ".config/wireplumber/main.lua.d/51-disable-suspension.lua".source =
          ./configs/wireplumber/51-disable-suspension.lua;
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

        extraConfig = {
          commit = {
            verbose = true;
          };
        };

        signing = {
          key = null;
          signByDefault = true;
        };
      };
    };
  };
}
