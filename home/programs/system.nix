{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
   # Dolphin FileManager
    kdePackages.dolphin
    kdePackages.ark            
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs
    
   
    jq
    playerctl
   
    # ==========================================================================
    # DESKTOP 
    # ==========================================================================

      #Uncomment this if you are no gonna use quickshell
    #swaync
    waybar
    rofi
    wlogout

    # ==========================================================================
    # NOTIFICATIONS / SYSTEM UTILITIES
    # ==========================================================================

    libnotify
    networkmanagerapplet
    imagemagick

    # ==========================================================================
    # WAYLAND UTILITIES
    # ==========================================================================

    wtype
    wev
  ];
}