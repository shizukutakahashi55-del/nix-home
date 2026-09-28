{ config, pkgs, inputs, ... }:

{
  imports = [
    # ───────────────────────────────────────────
    # Programas (antes en modules/programs/*, ahora
    # a nivel usuario en vez de systemPackages)
    # ───────────────────────────────────────────

    ./programs/browsers.nix
    ./programs/communication.nix
    ./programs/development.nix
    ./programs/gaming.nix
    ./programs/media.nix
    ./programs/system.nix
    ./programs/terminal.nix
    ./programs/gtk.nix
    ./programs/japanese.nix
  ];

  # ─────────────────────────────────────────────
  # Identidad
  # ─────────────────────────────────────────────

  home.username = "oozenix";
  home.homeDirectory = "/home/oozenix";

  # No la cambies al actualizar el flake: fija el formato de los archivos
  # de estado de Home Manager a la versión con la que arrancaste, igual
  # que system.stateVersion en configuration.nix.
  home.stateVersion = "26.05";

  # Deja instalado `home-manager` como comando dentro del propio perfil
  # de usuario 
  programs.home-manager.enable = true;
}
