{ config, pkgs, inputs, ... }:

{
  imports = [
    # ─────────────────────────────────────────────
    # Aplicaciones y herramientas
    # ─────────────────────────────────────────────

    ./programs/browsers.nix
    ./programs/communication.nix
    ./programs/development.nix
    ./programs/gaming.nix
    ./programs/terminal.nix

    # ─────────────────────────────────────────────
    # Escritorio
    # ─────────────────────────────────────────────

    ./programs/desktop.nix
    ./programs/wayland.nix
    ./programs/theming.nix
    ./programs/wallpaper.nix

    # ─────────────────────────────────────────────
    # Multimedia
    # ─────────────────────────────────────────────

    ./programs/media.nix
    ./programs/audio.nix

    # ─────────────────────────────────────────────
    # Sistema y archivos
    # ─────────────────────────────────────────────

    ./programs/files.nix
    ./programs/system.nix

    # ─────────────────────────────────────────────
    # Idiomas
    # ─────────────────────────────────────────────

    ./programs/japanese.nix
  ];

  # ─────────────────────────────────────────────
  # Identidad
  # ─────────────────────────────────────────────

  home.username = "oozenix";
  home.homeDirectory = "/home/oozenix";

  # No la cambies al actualizar el flake: fija el formato de los archivos
  # de estado de Home Manager a la versión con la que arrancaste.
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
