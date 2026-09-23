{ config, pkgs, inputs, ... }:

{
  imports = [
    # ───────────────────────────────────────────
    # Hardware
    # ───────────────────────────────────────────

    ./hardware-configuration.nix

    # ───────────────────────────────────────────
    # Sistema
    # ───────────────────────────────────────────

    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/nvidia.nix
    ./modules/users.nix
    ./modules/hyprland.nix

    # ───────────────────────────────────────────
    # Programas que se quedan a nivel sistema
    # (ver README: son los que necesitan algo que
    # Home Manager no puede darles por su cuenta —
    # librerías/drivers del sistema, plugins que
    # tiene que encontrar una sesión de escritorio
    # a nivel sistema, o wrappers setuid)
    # ───────────────────────────────────────────

    ./modules/programs/kde.nix
    ./modules/programs/obs.nix
    ./modules/programs/steam.nix
    ./modules/programs/suwayomi.nix

    # ───────────────────────────────────────────
    # Servicios
    # ───────────────────────────────────────────

    ./modules/services/flatpak.nix

  ];

  # ─────────────────────────────────────────────
  # Home Manager
  # ─────────────────────────────────────────────
  # El resto de los "programas" (navegadores, comunicación, desarrollo,
  # gaming, multimedia, utilidades de CLI, terminal) ahora se instalan acá,
  # a nivel de usuario, en vez de con environment.systemPackages. Ver
  # ./home/default.nix.

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Si algún día tenías un dotfile puesto a mano que choca con uno que
    # ahora gestiona Home Manager, en vez de fallar el build, lo renombra
    # con este sufijo así no perdés nada.
    backupFileExtension = "hm-backup";

    extraSpecialArgs = { inherit inputs; };

    users.oozenix = import ./home;
  };

  # ─────────────────────────────────────────────
  # Nix & System Configuration
  # ─────────────────────────────────────────────

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Habilita paquetes propietarios en todo el sistema
  nixpkgs.config.allowUnfree = true;

  # Versión inicial de NixOS
  system.stateVersion = "26.05";
}