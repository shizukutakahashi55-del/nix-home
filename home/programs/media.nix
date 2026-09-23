{ config, pkgs, inputs, ... }:

{

  
  # ─────────────────────────────────────────────
  # Media
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
  
    mpv      # Media player general use
    vlc      # Video Player VLC
    nomacs   # Image Vierwer

  ];

}
