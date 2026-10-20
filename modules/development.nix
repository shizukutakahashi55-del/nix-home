{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    #loadInNixShell = true;
    #direnvrcExtra = "";
    nix-direnv.enable = true;
  };

  # Docker Virtualization
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    users.users.oozenix.extraGroups = [ "docker" ];

  # NixPackages
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
    openssl

    # Java 
    openjdk
    jdk17
    jdk21
    jdk25

    # Python
    python3Packages.pip
    python314Packages.pandas
    
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

     ##Wayland
    #  wayland-protocols
    #  wayland.dev
    #  waylandpp

    #Installer
  ];
}
