{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # HYPRLAND & HYPR ECOSYSTEM
  # ============================================================================
  
  programs.hyprland = {
    enable = true;
    #withUWSM = true;
    xwayland.enable = true;

    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}
        .xdg-desktop-portal-hyprland;
  };

  # # XDG desktop portal for Hyprland
  # systemd.user.services."xdg-desktop-portal-hyprland" = {
  #   environment = {
  #     QT_STYLE_OVERRIDE = "Fusion";
  #   };
  # };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [

    # HYPRLAND ECOSYSTEM
    hyprpicker
    hyprsunset
    hyprshutdown
    hyprsysteminfo
    hypridle
 
  ];
}
