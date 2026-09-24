{ pkgs, lib, ... }:

{
  # ─────────────────────────────────────────────
  # Cursor
  # ─────────────────────────────────────────────
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # ─────────────────────────────────────────────
  # Tema GTK
  # ─────────────────────────────────────────────
  gtk = {
    enable = true;

    theme = {
      name = lib.mkForce "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # ─────────────────────────────────────────────
  # Variables de entorno de sesión
  # ─────────────────────────────────────────────
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };
}