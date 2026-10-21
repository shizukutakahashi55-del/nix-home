{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Video
    mpv
    vlc
    ffmpeg
    #parabolic
    

    # Images
    nomacs
    imagemagick
    
    #Installer
  ];
}
