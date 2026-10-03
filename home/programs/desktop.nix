{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # App store / desktop software
    bazaar
   
    # Bars / launchers / session controls
    waybar
    rofi
    wlogout

    # Desktop utilities
    wlsunset
    libnotify
    networkmanagerapplet

    # Uncomment if Quickshell is not used.
    # swaync
  ];
}
