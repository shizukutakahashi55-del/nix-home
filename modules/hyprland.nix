{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # HYPRLAND & HYPR ECOSYSTEM
  # ============================================================================
  
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;

    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}
        .xdg-desktop-portal-hyprland;
  };

  # Screen locker
  # programs.hyprlock.enable = true;

  # Idle / power management
  # programs.hypridle.enable = true;

  # XDG desktop portal for Hyprland
  systemd.user.services."xdg-desktop-portal-hyprland" = {
    environment = {
      QT_STYLE_OVERRIDE = "Fusion";
    };
  };



  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [

    # ==========================================================================
    #   HYPRLAND ECOSYSTEM
    # ==========================================================================
    
    ##hyprpolkitagent
    hyprpicker
    hyprpaper
    hyprshot
    hyprsunset
    hyprshutdown
    hyprsysteminfo
    hypridle
    hyprlock
 
  # If you see this commented, it's not an error, it's cuz, 
  # I often forget what to install on my setup. Don't uncomment this
  # the packages are already on Nix-Home-Manager modules

    # # ==========================================================================
    # # DESKTOP 
    # # ==========================================================================

    #   #Uncomment this if you are no gonna use quickshell
    # #swaync
    # waybar
    # rofi
    # wlogout

    # # ==========================================================================
    # # WALLPAPERS / THEMING
    # # ==========================================================================

    # awww
    # waypaper
    # matugen
    # qt6Packages.qt6ct

    # # ==========================================================================
    # # AUDIO / MULTIMEDIA
    # # ==========================================================================

    # pavucontrol
    # cava
    # ffmpeg
    # mpvpaper
    # socat
    # qpwgraph

    # # ==========================================================================
    # # SCREENSHOTS / CLIPBOARD
    # # ==========================================================================

    # grim
    # slurp
    # wl-clipboard

    # # ==========================================================================
    # # NOTIFICATIONS / SYSTEM UTILITIES
    # # ==========================================================================

    # libnotify
    # networkmanagerapplet
    # imagemagick

    # # ==========================================================================
    # # WAYLAND UTILITIES
    # # ==========================================================================

    # wtype
    # wev
  ];
}
