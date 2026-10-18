{ pkgs, ... }:

{
  home.packages = with pkgs; [
  # Game performance and monitoring
  gamemode
  mangohud
  goverlay

  # Game launchers
  heroic
  lutris

  # Proton compatibility
  protonplus
  protontricks
  
  #Installer
  ];
}
