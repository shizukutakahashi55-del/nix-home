{ pkgs, inputs, ... }:

{
  # ─────────────────────────────────────────────
  # Linux Packages
  # ─────────────────────────────────────────────
   # environment.systemPackages = [ inputs.amane.packages.x86_64-linux.default ];

    
    # Dolphin: application menu outside KDE Plasma
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";


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
    nunito
    nunito-sans
    mplus-outline-fonts.osdnRelease
    mplus-outline-fonts.githubRelease
    migu                           # opcional, japonés
    (google-fonts.override {
      fonts = [ "Silkscreen" "DotGothic16" "VT323" ];
    })
  ];
}