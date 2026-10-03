{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Audio control / visualization
    pavucontrol
    qpwgraph
    cava
    playerctl

    # Music
    spotify

    # Audio / media helpers
    socat
  ] ++ [
    inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
