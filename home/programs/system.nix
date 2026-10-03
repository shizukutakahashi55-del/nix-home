{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hardware / system controls
    brightnessctl
    liquidctl

    # General system/data utilities
    jq
  ];
}
