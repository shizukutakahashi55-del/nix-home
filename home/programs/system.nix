{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # System / CLI
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    jq
    playerctl
    swayosd
  ];
}
