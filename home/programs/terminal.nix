{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Terminal
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    
    #alacritty
    ghostty
    wezterm
    foot
    btop
    eza          #Reemplazo moderno e interactivo de ls con iconos y árbol de archivos.
    fastfetch
    fd
    fzf
    kitty
    ripgrep      #Reemplazo ultrarrápido de grep respetando archivos .gitignore.
    starship
    neovim
    zsh
    yazi         #Cli-FileBrowser
  ];
}
