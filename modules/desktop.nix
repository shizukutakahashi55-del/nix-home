{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # X11
  # ─────────────────────────────────────────────

  services.xserver.enable = true;

  # ─────────────────────────────────────────────
  # Display Manager
  # ─────────────────────────────────────────────

  services.displayManager.sddm = {
      enable = true;
      # 1. Usamos la ruta directa del paquete para que NixOS enlace el tema
      theme = "${pkgs.sddm-astronaut}";

      extraPackages = with pkgs; [
        sddm-astronaut
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtsensors
      ];
    };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
  # ─────────────────────────────────────────────
  # Printing
  # ─────────────────────────────────────────────

  services.printing.enable = true;

  # ─────────────────────────────────────────────
  # Fonts
  # ─────────────────────────────────────────────

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}