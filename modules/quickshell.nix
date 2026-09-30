{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [

    # --------------------------------------------------------------------------
    # QUICKSHELL
    # --------------------------------------------------------------------------

    # Quickshell wrapper with QML modules
    (symlinkJoin {
      name = "quickshell-wrapped";
      paths = [ quickshell ];

      nativeBuildInputs = [ makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/quickshell \
          --prefix QML2_IMPORT_PATH : "${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}"
      '';
    })
  ];
}
