{ pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Gaming Packages & Utilities
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    gamemode
    lutris
    mangohud
    prismlauncher
    protonplus
    wine
    protontricks
    goverlay
    
  ];
}
