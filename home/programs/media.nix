{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Video
    mpv
    vlc
    ffmpeg
    #parabolic #YT VideoDownloader
    

    # Images
    nomacs
    imagemagick
    
    #Installer
  ];
}
