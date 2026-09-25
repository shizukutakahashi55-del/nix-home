{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Límite de generaciones en el ESP
  # ─────────────────────────────────────────────
 
  boot.loader.systemd-boot.configurationLimit = 10;

  # ─────────────────────────────────────────────
  # Garbage collection automático
  # ─────────────────────────────────────────────

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
  };

  # Deduplica automáticamente derivaciones idénticas en el store.
  nix.settings.auto-optimise-store = true;

  # ─────────────────────────────────────────────
  # Mantenimiento de Btrfs
  # ─────────────────────────────────────────────
# Comment this section if you don't use btrfs.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.fstrim.enable = true;
}
