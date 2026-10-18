{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    # Terminal emulators
    # alacritty
    # ghostty
    # wezterm
    foot
    kitty

    # Shell / prompt
    zsh
    starship

    # CLI tools
    btop
    #bottom
    eza
    fastfetch
    fd
    ripgrep
    yazi
    neovim
    # tmux

    # Archives
    unzip
    zip

    #Installer
  ];
}
