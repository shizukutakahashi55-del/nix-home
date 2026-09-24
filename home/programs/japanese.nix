{ pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Método de Entrada (IME para Japonés en Home Manager)
  # ─────────────────────────────────────────────
  i18n.inputMethod = {
    enable = true; # Sintaxis correcta (en lugar de enabled = true)
    type = "fcitx5"; # Define Fcitx5 como el IME principal

    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc                    # Motor de japonés (Mozc)
        fcitx5-gtk                     # Soporte para aplicaciones GTK
        qt6Packages.fcitx5-configtool  # Interfaz gráfica de configuración (Qt6)
      ];
    };
  };

  # Variables de entorno
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE  = "fcitx";
    XMODIFIERS    = "@im=fcitx";
  };
}
