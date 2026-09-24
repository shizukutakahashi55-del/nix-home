{ pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Método de Entrada (IME para Japonés en Home Manager)
  # ─────────────────────────────────────────────
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc                   # Motor de japonés (Mozc)
        fcitx5-gtk                    # Soporte para aplicaciones GTK
        qt6Packages.fcitx5-configtool # Interfaz gráfica de configuración (Qt6)
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
