{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # File manager
    kdePackages.dolphin

    # Archives
    kdePackages.ark

    # Dolphin previews / thumbnails
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs
  ];
}
