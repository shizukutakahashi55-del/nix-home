{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Input / Wayland inspection
    wtype
    wev

    # Screenshots
    grim
    slurp

    # Clipboard
    cliphist
    wl-clipboard
    wl-clip-persist

    xwayland-satellite

  ];
}
