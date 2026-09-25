{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Terminal
  # ─────────────────────────────────────────────
    programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    
    #alacritty
    ghostty
    wezterm
    foot
    btop
    eza          #Reemplazo moderno e interactivo de ls con iconos y árbol de archivos.
    fastfetch
    fd
    kitty
    ripgrep      #Reemplazo ultrarrápido de grep respetando archivos .gitignore.
    starship
    neovim
    unzip
    zsh
    zip
    yazi         #Cli-FileBrowser
  ];
}
