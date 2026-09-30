{ config, pkgs, inputs, ... }:

{

  
  # ─────────────────────────────────────────────
  # Media
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    
    
    mpv      # Media player general use
    vlc      # Video Player VLC
    nomacs   # Image Vierwer
    
    # ==========================================================================
    # WALLPAPERS / THEMING
    # ==========================================================================

    awww
    waypaper
    matugen
    qt6Packages.qt6ct

    # ==========================================================================
    # AUDIO / MULTIMEDIA
    # ==========================================================================

    pavucontrol
    cava
    ffmpeg
    mpvpaper
    socat
    qpwgraph

    # ==========================================================================
    # SCREENSHOTS / CLIPBOARD
    # ==========================================================================

    grim
    slurp
    wl-clipboard
  ];

}
