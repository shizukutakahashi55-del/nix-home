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
    
  ];
}