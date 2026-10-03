{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Video
    mpv
    vlc
    ffmpeg

    # Images
    nomacs
    imagemagick
  ];
}
