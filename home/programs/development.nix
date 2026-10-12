{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # Git / Nix
    git
    gh
    nixd
    nixfmt-rfc-style
    nix-search-cli
    lazygit

    # Languages / runtimes
    jdk21
    python3
    python3Packages.pip
    ruff
    uv


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
    qt6.qtdeclarative #Added this here cuz an external proyect with rust + qml

    # Editors / utilities
    vscodium-fhs
    vim
    curl
    wget
    tree


    wayland-protocols
    wayland.dev
    waylandpp
  ];
}
