# OozeLogin

Greeter para greetd hecho con Quickshell, con ventana de configuración propia y conexión opcional con OozeShell.

## Instalación

1. Copia esta carpeta junto a tu configuración, por ejemplo `modules/oozelogin/`.
2. Reemplaza tu bloque de tuigreet por el contenido de `configuration-snippet.nix` (ver `imports = [ ./oozelogin ];`).
3. Asegúrate de que tu usuario esté en el grupo `users` (o cambia `services.oozelogin.group`).
4. `sudo nixos-rebuild switch`

## Comandos

| Comando | Qué hace |
|---|---|
| `oozelogin-settings` | Ventana de configuración (apariencia, paneles, acceso, clima, OozeShell) |
| `oozelogin-preview` | Abre el greeter en una ventana de prueba (contraseña de prueba: `ooze`) |
| `oozelogin-sync` | Copia colores, fondo y avatar de OozeShell al greeter |

El botón **Probar** de la ventana de ajustes lanza la misma vista previa.

## Conexión con OozeShell

`oozelogin-sync` lee `~/.cache/oozeshell/colors.json` (matugen), el fondo actual de awww y `~/.config/oozeshell/profile.json`, y lo copia a `/var/lib/oozelogin`. Con `sync.enable = true` se ejecuta solo cada vez que cambian esos archivos. En la página **OozeShell** de los ajustes activas el uso de esos colores y ese fondo.

Para abrir los ajustes desde OozeShell puedes lanzar `oozelogin-settings` desde un atajo o un botón.

## Notas

- Si Hyprland muestra un aviso por no iniciarse con `start-hyprland`, usa `services.oozelogin.compositorCommand` con tu propio comando; la config generada está en `config.services.oozelogin.compositorConfig`.
- En máquinas virtuales o equipos lentos desactiva el cristal desenfocado en Apariencia.
- Reiniciar y apagar funcionan gracias a una regla polkit para el usuario `greeter`.
