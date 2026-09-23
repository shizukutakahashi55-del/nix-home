{ config, pkgs, ... }:

{

  # ---------------------------------------------------------------------------
  # Home packages
  # Web Browsers
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [

    brave
    librewolf
    vivaldi
  ];

}
