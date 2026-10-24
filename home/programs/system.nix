{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hardware / system controls
    gnome-disk-utility
    brightnessctl
    liquidctl
    # nvtopPackages.full

    # General system/data utilities
    jq
    # poppler-utils
    # squashfsTools

    # Screen Recording
    wf-recorder
    xdg-utils
    xdg-user-dirs
    pulseaudio

    #Installer
  ];
}
