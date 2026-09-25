{ config, pkgs, ... }:

{
  # direnv + nix-direnv, con el hook correcto en la shell. Antes se
  # instalaban los paquetes sueltos vía home.packages, lo cual NO conecta
  # nix-direnv con direnv ni carga el hook: `direnv` quedaba instalado pero
  # inutilizable.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ─────────────────────────────────────────────
  # Development
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    curl
    git
    gh
    jdk21
    lazygit
    python3
    python3Packages.pip
    vscodium-fhs
    nixd 
    nixfmt-rfc-style
    nix-search-cli
    ruff
    tree
    qt6.qtquick3d
    qt6.qtdeclarative
    uv 
    wget
    vim

    # C++ Build Tools
    gcc
    gnumake
    cmake
    pkg-config 
  ];

}
