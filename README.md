# ❄️ NixOS Configuration

A modular NixOS configuration using **Flakes** and **Home Manager**,
with Hyprland, niri, MangoWM, QuickShell, NVIDIA support, gaming tools,
and development packages.

This repository is tailored to my own PC. **Do not apply it without
reviewing the machine-specific settings first.** My desktop dotfiles are
maintained separately in
[dotfiles-nix](https://github.com/shizukutakahashi55-del/dotfiles-nix).

## What's included

-   **Window managers:** Hyprland, niri, and MangoWM.
-   **Desktop:** QuickShell, lock/idle tools, wallpapers, screenshots,
    clipboard utilities, and theming.
-   **System:** PipeWire, Bluetooth, NetworkManager, Flatpak, polkit,
    and QEMU.
-   **Graphics:** NVIDIA drivers and OBS/CUDA configuration. An AMD
    alternative may be available in the modules.
-   **Gaming:** Steam with Millennium, Lutris, Wine/Proton tools,
    MangoHud, and Prism Launcher.
-   **Apps:** Browsers, communication, development, terminal, file
    management, and multimedia tools configured with Home Manager.
-   **Installer:** A QuickShell GUI for editing supported Nix files,
    reviewing changes, and building/testing/applying the configuration.

## Before installing

Requirements:

-   An existing **NixOS 26.05** installation.
-   `x86_64-linux` and UEFI.
-   Git and Flakes enabled.

This configuration includes hardware- and user-specific values. Review
at least:

-   `hardware-configuration.nix`
-   `modules/users.nix` and `home/default.nix`
-   `modules/networking.nix`
-   `flake.nix` and `configuration.nix`
-   GPU and filesystem-related modules

Do not reuse the repository's `hardware-configuration.nix` on another
machine.

## Installation

### 1. Clone the repository

``` bash
git clone https://github.com/shizukutakahashi55-del/nix-home.git ~/nix-home
cd ~/nix-home
```

### 2. Generate your hardware configuration

From the cloned repository, replace the included hardware configuration
with the one for your current installation:

``` bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Check the generated file before continuing.

### 3. Find and change the username

First, find the username you are currently logged in as:

```bash
whoami
```

To see your home directory:

```bash
printf '%s\\n' "$HOME"
```

You can also list regular user accounts configured on the system:

```bash
getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1, $6}'
```

Before rebuilding, replace the example username `oozenix` with your own
username wherever it is hard-coded. Check these files first:

- `modules/users.nix`
- `home/default.nix`
- Any other module that contains `oozenix` or `/home/oozenix`

Find occurrences from the repository root with:

```bash
grep -RIn --exclude-dir=.git 'oozenix' .
```

Edit each relevant occurrence and use your actual username and home
directory. Do not blindly replace every match: check whether each occurrence
is a username, a path, or an unrelated string.

### 4. Adapt the rest of the configuration

Update the hostname, timezone, locale, GPU, and any filesystem-specific
settings to match your machine.

The flake currently defines the host as `nixos`, so the rebuild commands
below use `.#nixos`. If you rename the host in `flake.nix`, update the
commands accordingly.

For an AMD system, review the GPU imports in `configuration.nix` and the
OBS module before building. Do not enable both GPU configurations
blindly.

### 5. Add new files to Git

Flakes use files tracked by Git. Check what will be included before
staging:

``` bash
git status --short
```

Stage the files you intend to include, for example:

``` bash
git add hardware-configuration.nix configuration.nix flake.nix modules home
```

If you intentionally want to stage every change, use `git add -A` after
reviewing `git status`.

### 6. Build and apply

First, check whether the configuration can build:

``` bash
sudo nixos-rebuild dry-build --flake .#nixos
```

Then activate it:

``` bash
sudo nixos-rebuild switch --flake .#nixos
```

Reboot if required by the changes:

``` bash
reboot
```

Home Manager is integrated into the NixOS configuration, so you do not
need to run `home-manager switch` separately.

## Common commands

Run these from the repository directory.

| Command | Purpose |
|---|---|
| `nix flake update` | Update flake inputs and rewrite `flake.lock`. Review changes before applying them. |
| `sudo nixos-rebuild dry-build --flake .#nixos` | Check whether the configuration builds without activating it. |
| `sudo nixos-rebuild build --flake .#nixos` | Build the system configuration without activating it. |
| `sudo nixos-rebuild test --flake .#nixos` | Activate the configuration temporarily; it will not become the boot default. |
| `sudo nixos-rebuild switch --flake .#nixos` | Build and activate the configuration and make it the current system generation. |
| `sudo nixos-rebuild switch --rollback` | Switch to the previous system generation. |
| `git status --short` | Show modified and untracked files. |
| `git diff` | Review unstaged changes. |

If you add or rename files imported by the flake, make sure they are
tracked by Git before rebuilding. Avoid running `nix flake update`
unless you intend to update dependencies.

**Tip:** Changes to the compositor or display manager can end your
graphical session. Apply those changes from a TTY, or build with
`sudo nixos-rebuild boot --flake .#nixos` and reboot.

## Graphical installer

The `installer/` directory contains a QuickShell GUI for managing
supported `.nix` files in this repository.

If QuickShell and `nix-search-cli` are not already available in your
environment, you can launch the installer with:

``` bash
nix shell -p quickshell nix-search-cli -c ./installer/run.sh
```

Otherwise, run:

``` bash
./installer/run.sh
```

To toggle the installer from a keybinding:

``` bash
./installer/toggle.sh
```

To force it to close even if a command is running:

``` bash
./installer/toggle.sh --force
```

The installer includes package search/editing, a change review, a Nix
file editor, and controls to validate, test, and apply changes. Review
each change before applying it. The installer does not replace the need
to understand the configuration you're modifying.

The Rust backend is built outside the repository by default, under
`~/.cache/nix-home-installer/target`. You can override the build
location with `CARGO_TARGET_DIR`.

## Repository layout

```text
.
├── flake.nix
├── flake.lock
├── configuration.nix
├── hardware-configuration.nix
├── modules/       # System modules, drivers, services, and system-level programs
├── home/          # Home Manager configuration and user applications
├── modules/oozelogin/  # OozeLogin: QuickShell greeter for greetd
└── installer/     # QuickShell interface and Rust backend
```

## OozeLogin (login screen)

`modules/greetd.nix` enables OozeLogin, a QuickShell greeter for greetd with
its own settings window. It replaces tuigreet.

| Command | Purpose |
|---|---|
| `oozelogin-settings` | Settings window (appearance, panels, access, weather, OozeShell) |
| `oozelogin-preview` | Run the greeter in a window to test it (test password: `ooze`) |
| `oozelogin-sync` | Copy OozeShell colors, wallpaper and avatar to the greeter |

`sync.enable = true` runs the sync automatically whenever the matugen
palette, the awww wallpaper or the OozeShell profile change. Your user must
be in the `users` group to edit the greeter settings. Details in
`modules/oozelogin/README.md`.

**Tip:** test with `oozelogin-preview` first, and apply with
`sudo nixos-rebuild boot --flake .#nixos` followed by a reboot. If the login
screen fails, switch to another TTY (Ctrl+Alt+F2) and run
`sudo nixos-rebuild switch --rollback`.

## Important notes

-   **System version:** Keep `system.stateVersion` and Home Manager's
    `home.stateVersion` consistent with the version used when the system
    was first installed. Do not change them just to upgrade NixOS.
-   **NVIDIA environment:** `modules/nvidia.nix` sets graphics-related
    environment variables. If your compositor config sets the same
    variables, keep the values consistent.
-   **Polkit:** Review `modules/polkit.nix`; it defines which privileged
    power actions can be performed without a password.
-   **Maintenance:** Review `modules/maintenance.nix` and make sure its
    Btrfs maintenance settings match your filesystem.
-   **External inputs:** `nix flake update` can introduce upstream
    changes. Review the diff and keep `flake.lock` committed when the
    configuration is in a known-good state.
-   **New files:** Add newly created files to Git before rebuilding so
    the flake can include them.

Review the configuration and its security implications before using it
on a machine you care about.
