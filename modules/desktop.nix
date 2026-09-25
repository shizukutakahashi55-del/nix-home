{ pkgs, ... }:

{

  # Enable AppImage Support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;


  # ─────────────────────────────────────────────
  # Display Manager: greetd + tuigreet
  # ─────────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ─────────────────────────────────────────────
  # Printing & Fonts
  # ─────────────────────────────────────────────
  services.printing.enable = true;

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}