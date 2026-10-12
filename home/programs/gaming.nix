{ pkgs, ... }:

{
  home.packages = with pkgs; [
  # Game performance and monitoring
  gamemode
  mangohud
  goverlay

  # Game launchers
  heroic-unwrapped
  lutris
  prismlauncher-unwrapped
  retroarch-full

  # Wine and Proton compatibility
  wine
  protonplus
  protontricks
  ];
}
