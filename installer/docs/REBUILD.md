# Rebuild manual con el instalador dentro del repo

## Por qué fallaba

`nixos-rebuild --flake` copia el código fuente del flake al `/nix/store` antes de evaluarlo.

- Si el directorio **no es un repositorio git**, se copia todo, incluida `installer/target/` (la salida de `cargo build`, cientos de MB y miles de archivos). Nix puede fallar o tardar muchísimo al copiarla.
- Si es un repositorio git, solo se copian los archivos que git conoce. Los archivos nuevos sin `git add` no existen para el flake, y `target/` solo queda fuera si está ignorado.
- La aplicación y la terminal pueden comportarse distinto si apuntan a rutas diferentes (`/etc/nixos`, `~/nix-home`, `.`) o si `sudo` corre como root sobre un repositorio de otro usuario.

## Qué cambió

`installer/run.sh` ahora compila el backend fuera del repo:

| Variable | Valor por defecto |
|---|---|
| `CARGO_TARGET_DIR` | `~/.cache/nix-home-installer/target` |
| Binario | `$CARGO_TARGET_DIR/release/nix-home-installer` |

Así `installer/` solo contiene código fuente y el flake no ve ningún artefacto de compilación.

## Pasos para aplicar

```bash
cd ~/nix-home
rm -rf installer/target
git add -A
sudo nixos-rebuild switch --flake .#nixos
```

Si el repo está en `/etc/nixos` y no es git, inicialízalo una vez:

```bash
cd /etc/nixos
git init
git add -A
```

## Si sigue fallando

Ejecuta el rebuild con `--show-trace` y revisa la primera línea que empiece con `error:`. Los casos más comunes:

| Mensaje | Causa | Solución |
|---|---|---|
| `has an unsupported type` | Hay sockets o archivos especiales dentro del árbol | Mover o borrar ese archivo, o usar git |
| `dubious ownership` / `not owned by current user` | `sudo` sobre un repo de otro usuario | `sudo git config --global --add safe.directory <ruta>` |
| `path ... does not exist` | Archivo nuevo sin `git add` | `git add -A` |
