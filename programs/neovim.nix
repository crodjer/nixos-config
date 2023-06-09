{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = builtins.readFile ./configs/init.vim;
      packages.myVimPackages = with pkgs.vimPlugins; {
        start = [ 
          ale
          vim-nix
          rust-vim
          vim-ledger
          fzf-vim
          lightline-vim
          lightline-ale
          nvim-autopairs
          tagbar
        ];
      };
    };
  };
}
