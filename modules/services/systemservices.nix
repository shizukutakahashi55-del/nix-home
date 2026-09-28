{ ... }:

{
  # ─────────────────────────────────────────────
  # System services
  # ─────────────────────────────────────────────

  # Battery
  services.upower.enable = true;

  # Power Profiles
  services.power-profiles-daemon.enable = true;
}