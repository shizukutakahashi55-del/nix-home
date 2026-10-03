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
    qt6.qtquick3d
    qt6.qtdeclarative

    # Editors / utilities
    vscodium-fhs
    vim
    curl
    wget
    tree
  ];
}
