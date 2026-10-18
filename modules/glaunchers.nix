{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    # Wine Compatibility
    wineWow64Packages.stable
    #winetricks

    # PrismLauncher
    (prismlauncher.override {
      jdks = [ 
        temurin-bin-25
        temurin-bin-21 
        temurin-bin-17 
        temurin-bin-8 
      ];
    })

    # Retroarch with packages
    (retroarch.withCores (cores: with cores; [
      genesis-plus-gx
      snes9x
      beetle-psx-hw
    ]))
  ];
}