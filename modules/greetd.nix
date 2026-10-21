{ config, pkgs, ... }:

{
  imports = [ ./oozelogin ];

  services.oozelogin = {
    enable = true;
    compositor = "hyprland";
    compositorPackage = config.programs.hyprland.package;
    keyboardLayouts = [ "us" "latam" ];
    sync.enable = true;
    settings = {
      showStats = false;
      showWeather = false;
    };
  };
}
