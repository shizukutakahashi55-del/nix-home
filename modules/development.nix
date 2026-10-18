{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

   environment.systemPackages = with pkgs; [
    # Git / Nix
    git
    gh
    nixd
    nixfmt-rfc-style
    nix-search-cli
    lazygit

    # Runtimes
    ruff
    uv

    # Java 
    openjdk
    jdk17
    jdk21
    jdk25

    # Python
    python3Packages.pip
    
    # Rust
    rustc
    rustfmt
    cargo

    # C / C++
    gcc
    gnumake
    cmake
    pkg-config

    # Qt / QML
    qt6.qttools
    qt6.qtbase
    qt6.qmake
    qt6.qtquick3d
    qt6.qtdeclarative 

    # Editors / utilities
    vscodium-fhs
    vim
    curl
    wget
    tree

    # Wayland 
    wayland-protocols
    wayland.dev
    waylandpp

    #Installer
  ];
}
