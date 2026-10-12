# Nix Home Installer

Instalador gráfico (Quickshell) para el repositorio `nix-home`: buscar paquetes, añadirlos a tus archivos `.nix`, ver el diff, validar/probar/aplicar con la salida en vivo y corregir a mano si algo falla.

## Uso

```bash
./installer/run.sh
```

`run.sh` compila el backend la primera vez (`cargo`, o `nix-shell -p cargo rustc gcc` si no lo tienes) y lanza `quickshell -p installer/ui`. Necesitas `quickshell` y `nix-search-cli` en `PATH` (`nix shell nixpkgs#nix-search-cli`).

Variables opcionales: `NIXHOME_REPO` (ruta del repo), `NIXHOME_BACKEND` (binario), `NIXHOME_CHANNEL` (canal de nix-search; por defecto se lee de `flake.nix`, p. ej. `26.05`).

## Atajo para abrir / cerrar (toggle)

`installer/toggle.sh` abre el instalador y, si ya está abierto, **lo cierra y apaga el proceso** (no queda nada en segundo plano). Si hay un comando en ejecución (p. ej. un `switch`) no lo cierra y te avisa; `toggle.sh --force` lo cierra igualmente. Cerrar la ventana con tu gestor de ventanas, `Ctrl+Q` o el botón *Cerrar* de la barra también termina el proceso.

Ejemplos con `Super+Shift+U` (ajusta la ruta si tu repo no está en `~/nix-home`):

```lua
-- Hyprland (config en Lua)
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("~/nix-home/installer/toggle.sh"))
```
```ini
# Hyprland (hyprlang clásico)
bind = SUPER SHIFT, U, exec, ~/nix-home/installer/toggle.sh
```
```kdl
// niri  (repeat=false evita que al mantener la tecla se abra y cierre en bucle)
binds {
    Mod+Shift+U repeat=false hotkey-overlay-title="Instalador Nix Home" { spawn "~/nix-home/installer/toggle.sh"; }
}
```
```ini
# MangoWC  (spawn_shell para que se expanda el ~)
bind=SUPER+SHIFT,U,spawn_shell,~/nix-home/installer/toggle.sh
```

La pestaña **Ajustes** muestra estas líneas ya con tu ruta real y un botón para copiarlas. Internamente usa `quickshell ipc call installer close` (IPC de Quickshell).

## Ajustes de apariencia (Ctrl+5)

Se guardan en `~/.config/nix-home-installer/settings.json`:

- **Paleta**: Violeta (por defecto), Catppuccin Mocha, Tokyo Night, Rosé Pine, Dracula, Nord, Gruvbox, Everforest, Medianoche OLED y Catppuccin Latte (claro).
- **Color de acento** independiente de la paleta.
- **Esquinas** (rectas / suaves / redondas), **tamaño del texto** y **fuente monoespaciada**.
- **Opacidad del fondo**, **barra lateral compacta** y **animaciones**.

Para añadir tu propia paleta, copia un bloque de `themes` en `ui/Pal.qml`.

## Pestañas (Ctrl+1…5)

1. **Paquetes** — busca en nixpkgs (mismo canal que tu flake). El destino se sugiere por palabras clave (`catalog/categories.json`) y se puede cambiar. *Añadir* inserta el paquete en la lista `home.packages` / `environment.systemPackages` del archivo elegido (si estaba comentado como `# paquete`, lo descomenta). *Probar build* hace `nix build` del paquete contra el nixpkgs de tu sistema. El modo *En mi configuración* lista y quita los paquetes que ya tienes.
2. **Cambios** — diff de todo lo editado desde el último estado aceptado. *Deshacer todo* restaura los originales.
3. **Terminal** — `1 Validar` (`nixos-rebuild dry-build`, sin root) → `2 Probar` (`sudo nixos-rebuild test`) → `3 Aplicar` (`switch`). Las rutas `.nix:línea` de los errores son enlaces que abren el Editor en esa línea. Abajo hay una línea de comandos libre en tu repo.
4. **Editor** — (con números de línea) editor de texto para cualquier `.nix` del repo (Ctrl+S guarda, *Sintaxis* usa `nix-instantiate --parse`, *Editor externo* abre `$TERMINAL -e $EDITOR`).
5. **Ajustes** — apariencia y atajo (ver arriba).

## Seguridad

- Antes de la primera modificación de cada archivo se guarda una copia en `.installer/snapshots/` (ignorada por git). Tras un `switch` correcto se aceptan los cambios y se borran los snapshots.
- Solo se editan archivos `.nix` dentro del repo; nunca se ejecuta `test`/`switch` sin que pulses el botón.
- La contraseña de sudo se pide en un diálogo y solo vive en memoria; se entrega a `sudo -A` mediante `ui/askpass.sh` (variable de entorno del proceso hijo).

## Backend (`nix-home-installer`)

Sin dependencias. Todas las respuestas son una línea JSON `{ok, data, error}`:

```
status|targets|files|diff|revert|accept [repo]
add|remove <repo> <archivo.nix> <attr>
snapshot <repo> <archivo.nix>
```

Pruebas: `cargo test`.

## Limitaciones conocidas

- Solo toca listas simples (`pkg`, `pkgs.pkg`) de `home.packages` / `environment.systemPackages`; entradas complejas (`(symlinkJoin …)`) se respetan pero no se listan.
- `nixos-rebuild` evalúa el flake: los archivos *nuevos* deben estar añadidos a git (`git add`); aquí solo se editan existentes.
- Supone un sistema NixOS ya instalado (no cubre `nixos-install` desde el ISO).
