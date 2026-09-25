{ config, pkgs, inputs, ... }:

{

  # ─────────────────────────────────────────────
  # Communication
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    
    
    discord
    telegram-desktop
    spotify
    vesktop

    # Sonora native player for linux spotify
    inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default

  ];

}
