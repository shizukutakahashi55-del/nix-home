{ pkgs, inputs, ... }:

{
  # ─────────────────────────────────────────────
  # Linux Packages
  # ─────────────────────────────────────────────

  # Enable AppImage Support
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Module Linux Packages
  programs.nix-ld.enable = true;

  # ─────────────────────────────────────────────
  # Storage
  # ─────────────────────────────────────────────

  # Mount disks
  services.udisks2.enable = true;

  # ─────────────────────────────────────────────
  # Display Manager: greetd + tuigreet
  # ─────────────────────────────────────────────

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command =
          "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session";
        user = "greeter";
      };
    };
  };

  # ─────────────────────────────────────────────
  # Printing & Fonts
  # ─────────────────────────────────────────────

  services.printing.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono      # íconos (obligatoria)
    nerd-fonts.symbols-only        # respaldo de glifos
    migu                           # opcional, japonés
    (google-fonts.override {
      fonts = [ "Silkscreen" "DotGothic16" "VT323" ];
    })
  ];
}