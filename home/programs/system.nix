{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
   
    kdePackages.dolphin
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs
   
    jq
    playerctl
    
  ];
}