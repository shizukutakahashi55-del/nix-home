{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Communication
  # ─────────────────────────────────────────────

  environment.systemPackages = with pkgs; [

    # OBS con soporte CUDA. El LD_LIBRARY_PATH de las librerías NVIDIA se
    # aplica solo a este binario (con un wrapper), en vez de exportarlo para
    # toda la sesión: hacerlo global puede romper otros programas que cargan
    # sus propias librerías dinámicas y esperan encontrar las suyas primero.
    (symlinkJoin {
      name = "obs-studio-nvidia";
      paths = [ (obs-studio.override { cudaSupport = true; }) ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obs \
          --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
      '';
    })
  ];
}