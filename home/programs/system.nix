{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hardware / system controls
    gnome-disk-utility
    brightnessctl
    liquidctl
    nvtopPackages.v3d

    # General system/data utilities
    jq
  ];
}
