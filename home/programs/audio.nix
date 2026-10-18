{ pkgs, inputs, ... }:

{
  # ADD NEW SOFTWARE BY HAND IF POSIBLE IN THIS SECTION
  home.packages = with pkgs; [
    # Audio control / visualization
    pavucontrol
    qpwgraph
    cava
    playerctl

    # Audio / media helpers
    socat
    
    # Music
    spotify
    
  ] ++ [
    inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default
  
  #Installer

  ];

}
