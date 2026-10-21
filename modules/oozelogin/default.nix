{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.oozelogin;

  qs = cfg.quickshellPackage;

  compositorPkg =
    if cfg.compositorPackage != null then cfg.compositorPackage
    else if cfg.compositor == "niri" then pkgs.niri
    else pkgs.hyprland;

  layouts = lib.concatStringsSep "," cfg.keyboardLayouts;

  logFile = "${cfg.cacheDir}/greeter.log";

  logArg = lib.escapeShellArg logFile;

  coreutilsBin = "${pkgs.coreutils}/bin";

  readyFile = "${cfg.cacheDir}/greeter.ready";

  okFile = "${cfg.cacheDir}/greeter.ok";

  readyArg = lib.escapeShellArg readyFile;

  okArg = lib.escapeShellArg okFile;

  sessionsDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";

  baseConfig = pkgs.writeText "oozelogin-base.json" (builtins.toJSON cfg.settings);

  binPath = lib.makeBinPath (with pkgs; [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    curl
    systemd
    (lib.getBin pkgs.stdenv.cc.libc)
  ]) + ":/run/current-system/sw/bin";

  commonEnv = {
    OOZELOGIN_DIR = cfg.stateDir;
    OOZELOGIN_CACHE = cfg.cacheDir;
    OOZELOGIN_BASE = "${baseConfig}";
    OOZELOGIN_SESSIONS = sessionsDir;
    OOZELOGIN_COMPOSITOR = cfg.compositor;
    OOZELOGIN_LAYOUTS = layouts;
  } // cfg.extraEnv;

  envFlags = lib.concatStringsSep " " (lib.mapAttrsToList
    (name: value: "--set ${name} ${lib.escapeShellArg value}") commonEnv);

  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "oozelogin";
    version = "0.1.0";
    src = lib.cleanSource ./.;
    nativeBuildInputs = [ pkgs.makeWrapper pkgs.python3 ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/oozelogin $out/bin
      cp -r qml/. $out/share/oozelogin/
      install -Dm755 tools/oozelogin-sync $out/bin/oozelogin-sync
      patchShebangs $out/bin

      makeWrapper ${qs}/bin/quickshell $out/bin/oozelogin-greeter \
        --add-flags "-p $out/share/oozelogin/shell.qml" \
        --prefix PATH : ${binPath} \
        ${envFlags}

      makeWrapper ${qs}/bin/quickshell $out/bin/oozelogin-settings \
        --add-flags "-p $out/share/oozelogin/settings.qml" \
        --prefix PATH : ${binPath} \
        --set OOZELOGIN_QS ${qs}/bin/quickshell \
        --set OOZELOGIN_SYNC $out/bin/oozelogin-sync \
        ${envFlags}

      makeWrapper ${qs}/bin/quickshell $out/bin/oozelogin-preview \
        --add-flags "-p $out/share/oozelogin/shell.qml" \
        --prefix PATH : ${binPath} \
        --set OOZELOGIN_PREVIEW 1 \
        ${envFlags}

      wrapProgram $out/bin/oozelogin-sync \
        --set OOZELOGIN_DIR ${cfg.stateDir}
      runHook postInstall
    '';
  };

  greeterRun = pkgs.writeShellScript "oozelogin-run" ''
    {
      echo "--- oozelogin greeter start $(${coreutilsBin}/date -Is)"
      ${coreutilsBin}/id
      ${coreutilsBin}/env | ${coreutilsBin}/sort
      ${coreutilsBin}/ls -l /dev/dri
    } >>${logArg} 2>&1
    ${package}/bin/oozelogin-greeter >>${logArg} 2>&1
    status=$?
    echo "--- oozelogin greeter exited status=$status" >>${logArg}
    [ "$status" -eq 0 ] && [ -e ${readyArg} ] && : >${okArg}
    ${if cfg.compositor == "niri"
      then "${compositorPkg}/bin/niri msg action quit --skip-confirmation"
      else if cfg.hyprlandConfigFormat == "lua"
      then "${compositorPkg}/bin/hyprctl dispatch 'hl.dsp.exit()'"
      else "${compositorPkg}/bin/hyprctl dispatch exit"}
  '';

  hyprlangConfig = pkgs.writeText "oozelogin-hyprland.conf" ''
    monitor = , preferred, auto, 1

    input {
      kb_layout = ${layouts}
      kb_options = ${cfg.keyboardOptions}
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      force_default_wallpaper = 0
    }

    ecosystem {
      no_update_news = true
      no_donation_nag = true
    }

    animations {
      enabled = false
    }

    exec-once = ${greeterRun}
  '';

  hyprlandLuaConfig = pkgs.writeText "oozelogin-hyprland.lua" ''
    hl.monitor({
      output = "",
      mode = "preferred",
      position = "auto",
      scale = 1,
    })

    hl.config({
      input = {
        kb_layout = "${layouts}",
        kb_options = "${cfg.keyboardOptions}",
      },
      misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
      },
      ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
      },
      animations = {
        enabled = false,
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("${greeterRun}")
    end)
  '';

  hyprlandConfig =
    if cfg.hyprlandConfigFormat == "lua" then hyprlandLuaConfig else hyprlangConfig;

  niriConfig = pkgs.writeText "oozelogin-niri.kdl" ''
    input {
      keyboard {
        xkb {
          layout "${layouts}"
          options "${cfg.keyboardOptions}"
        }
      }
    }

    prefer-no-csd

    hotkey-overlay {
      skip-at-startup
    }

    spawn-at-startup "${greeterRun}"
  '';

  generatedConfig = if cfg.compositor == "niri" then niriConfig else hyprlandConfig;

  defaultCommand =
    if cfg.compositor == "niri"
    then "${compositorPkg}/bin/niri --config ${generatedConfig}"
    else if cfg.hyprlandConfigFormat == "lua"
    then "${compositorPkg}/bin/start-hyprland -- --config ${generatedConfig}"
    else "${compositorPkg}/bin/Hyprland --config ${generatedConfig}";

  compositorCmd =
    if cfg.compositorCommand != null then cfg.compositorCommand else defaultCommand;

  pkillBin = "${pkgs.procps}/bin/pkill";

  watchdogBlock = ''
    ${coreutilsBin}/rm -f ${readyArg} ${okArg}

    stop_compositor() {
      ${pkillBin} -TERM -P "$pid"
      n=0
      while kill -0 "$pid" 2>/dev/null && [ "$n" -lt 5 ]; do
        ${coreutilsBin}/sleep 1
        n=$((n + 1))
      done
      if kill -0 "$pid" 2>/dev/null; then kill "$pid"; fi
      n=0
      while kill -0 "$pid" 2>/dev/null && [ "$n" -lt 3 ]; do
        ${coreutilsBin}/sleep 1
        n=$((n + 1))
      done
      if kill -0 "$pid" 2>/dev/null; then kill -KILL "$pid"; fi
    }

    ${compositorCmd} >>${logArg} 2>&1 &
    pid=$!

    elapsed=0
    while kill -0 "$pid" 2>/dev/null && [ ! -e ${readyArg} ]; do
      if [ "$elapsed" -ge ${toString cfg.fallback.timeout} ]; then
        echo "--- oozelogin watchdog: greeter not ready after ${toString cfg.fallback.timeout}s" >>${logArg}
        stop_compositor
        break
      fi
      ${coreutilsBin}/sleep 1
      elapsed=$((elapsed + 1))
    done

    wait "$pid"
    status=$?
    echo "--- oozelogin compositor exited status=$status" >>${logArg}

    if [ -e ${okArg} ]; then
      exit 0
    fi

    echo "--- oozelogin starting fallback greeter" >>${logArg}
    exec ${cfg.fallback.command}
  '';

  greeterSession = pkgs.writeShellScript "oozelogin-session" ''
    export HOME=${cfg.cacheDir}/home
    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_STATE_HOME=$HOME/.local/state
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_CONFIG_HOME=$HOME/.config
    export QT_QPA_PLATFORM=wayland
    ${coreutilsBin}/mkdir -p "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"
    [ -f ${logArg} ] && ${coreutilsBin}/mv -f ${logArg} ${logArg}.old
    ${if cfg.fallback.enable then watchdogBlock else "exec ${compositorCmd} >>${logArg} 2>&1"}
  '';
in
{
  options.services.oozelogin = {
    enable = mkEnableOption "OozeLogin, a Quickshell greeter for greetd";

    quickshellPackage = mkOption {
      type = types.package;
      default = pkgs.quickshell;
      description = "Quickshell package used to run the greeter and the settings window.";
    };

    compositor = mkOption {
      type = types.enum [ "hyprland" "niri" ];
      default = "hyprland";
      description = "Compositor that hosts the greeter. It only lives while the login screen is shown.";
    };

    hyprlandConfigFormat = mkOption {
      type = types.enum [ "lua" "hyprlang" ];
      default = "lua";
      description = "Formato de la config que se le pasa a Hyprland con --config. Desde Hyprland 0.55 una config explicita se interpreta como Lua; usa hyprlang solo con versiones anteriores.";
    };

    compositorPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Overrides the compositor package.";
    };

    compositorCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Full command that starts the compositor. The generated config is exposed in compositorConfig.";
    };

    compositorConfig = mkOption {
      type = types.path;
      readOnly = true;
      default = generatedConfig;
      description = "Generated compositor config that starts the greeter.";
    };

    keyboardLayouts = mkOption {
      type = types.listOf types.str;
      default = [ "us" ];
      example = [ "latam" "us" ];
      description = "XKB layouts available on the login screen.";
    };

    keyboardOptions = mkOption {
      type = types.str;
      default = "";
      example = "grp:alt_shift_toggle";
      description = "XKB options for the login screen.";
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = "Group allowed to edit the greeter configuration.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/oozelogin";
      description = "Folder with config, wallpapers and avatars shared between the settings window and the greeter.";
    };

    cacheDir = mkOption {
      type = types.str;
      default = "/var/cache/oozelogin";
      description = "Writable folder for the greeter user (last user and session).";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = { brand = "OozeLogin"; weatherCity = "City"; bgBlur = 20; };
      description = "Declarative defaults. Values saved from the settings window take priority.";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables for the greeter and the settings window.";
    };

    fallback.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Si el greeter no arranca o termina sin que el inicio de sesion se complete, cae a un greeter de texto en lugar de dejar la pantalla inutilizable.";
    };

    fallback.command = mkOption {
      type = types.str;
      default = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session";
      description = "Comando del greeter de respaldo.";
    };

    fallback.timeout = mkOption {
      type = types.ints.positive;
      default = 20;
      description = "Segundos que se espera a que el greeter avise que esta listo antes de darlo por fallido.";
    };

    sync.enable = mkEnableOption "automatic sync of OozeShell colors, wallpaper and avatar to the greeter";

    package = mkOption {
      type = types.package;
      readOnly = true;
      default = package;
      description = "The built OozeLogin package.";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${greeterSession}";
        user = "greeter";
      };
    };

    environment.systemPackages = [ package ];

    fonts.packages = [ pkgs.nerd-fonts.symbols-only ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 2775 greeter ${cfg.group} -"
      "d ${cfg.stateDir}/wallpapers 2775 greeter ${cfg.group} -"
      "d ${cfg.stateDir}/avatars 2775 greeter ${cfg.group} -"
      "d ${cfg.cacheDir} 0755 greeter greeter -"
      "d ${cfg.cacheDir}/home 0700 greeter greeter -"
    ];

    security.polkit.enable = lib.mkDefault true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "greeter" &&
            (action.id.indexOf("org.freedesktop.login1.power-off") == 0 ||
             action.id.indexOf("org.freedesktop.login1.reboot") == 0)) {
          return polkit.Result.YES;
        }
      });
    '';

    systemd.user.services.oozelogin-sync = mkIf cfg.sync.enable {
      description = "Sync OozeShell theme to OozeLogin";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/oozelogin-sync --quiet";
      };
    };

    systemd.user.paths.oozelogin-sync = mkIf cfg.sync.enable {
      description = "Watch OozeShell theme changes";
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathChanged = [
          "%h/.cache/oozeshell/colors.json"
          "%h/.cache/awww/last"
          "%h/.config/oozeshell/profile.toml"
          "%h/.config/oozeshell/profile.json"
        ];
        Unit = "oozelogin-sync.service";
      };
    };
  };
}
