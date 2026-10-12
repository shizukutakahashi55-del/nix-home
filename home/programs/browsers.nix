{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Browsers
    brave 
    librewolf
    vivaldi
    firefox

    # Browsers Theming
    pywalfox-native
  ];
}
