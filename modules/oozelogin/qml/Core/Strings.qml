pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root

  property string runtimeLang: ""

  readonly property string detected: {
    const l = String(Quickshell.env("LANG") || Quickshell.env("LANGUAGE") || "en").toLowerCase()
    return l.indexOf("es") === 0 ? "es" : "en"
  }
  readonly property string lang: {
    if (root.runtimeLang !== "") return root.runtimeLang
    const c = Config.v.language
    return (c === "es" || c === "en") ? c : root.detected
  }

  readonly property var languages: [
    { code: "es", name: "Español" },
    { code: "en", name: "English" }
  ]

  readonly property var tables: ({
    es: {
      session: "Sesión",
      langKeyboard: "Idioma / Teclado",
      password: "Contraseña",
      restart: "Reiniciar",
      shutdown: "Apagar",
      sure: "¿Seguro?",
      wrong: "Contraseña incorrecta",
      authError: "No se pudo iniciar sesión",
      checking: "Verificando…",
      starting: "Iniciando sesión…",
      capsOn: "Bloq Mayús activado",
      battery: "Batería",
      cpu: "CPU",
      ram: "RAM",
      gpu: "GPU",
      wxClear: "Despejado",
      wxPartly: "Parcialmente nublado",
      wxCloudy: "Nublado",
      wxFog: "Niebla",
      wxDrizzle: "Llovizna",
      wxRain: "Lluvia",
      wxSnow: "Nieve",
      wxStorm: "Tormenta",
      previewHint: "Vista previa: contraseña de prueba «ooze»",
      kbLatam: "Español (Latinoamérica)",
      kbEs: "Español (España)",
      kbUs: "English (US)",
      kbGb: "English (UK)",
      kbBr: "Português (Brasil)",
      kbDe: "Deutsch",
      kbFr: "Français",
      kbIt: "Italiano",
      noSessions: "Sin sesiones",
      user: "Usuario",
      settingsTitle: "Ajustes de OozeLogin",
      navAppearance: "Apariencia",
      navInterface: "Interfaz",
      navAccess: "Acceso",
      navWeather: "Clima",
      navOozeShell: "OozeShell",
      preview: "Probar",
      reload: "Recargar",
      notWritable: "No hay permiso de escritura en {dir}. Revisa que tu usuario esté en el grupo configurado.",
      wallpaper: "Fondo",
      wallpaperHint: "Imágenes guardadas en la carpeta del greeter. Haz clic para elegir.",
      wallpaperNone: "Sin imágenes todavía",
      addImage: "Agregar imagen",
      addImageHint: "Ruta de una imagen para copiarla al greeter",
      add: "Agregar",
      wallpaperMode: "Modo de fondo",
      modeFixed: "Fijo",
      modeRandom: "Aleatorio",
      modeSync: "OozeShell",
      bgBlur: "Desenfoque del fondo",
      bgDim: "Oscurecer fondo",
      panelBlur: "Cristal desenfocado en paneles",
      panelBlurHint: "Desactívalo en equipos lentos o máquinas virtuales",
      panelOpacity: "Opacidad de paneles",
      panelRadius: "Redondeo de paneles",
      uiScale: "Escala de la interfaz",
      colors: "Colores",
      themeSource: "Origen del tema",
      themeCustom: "Personalizado",
      themeOoze: "OozeShell",
      colorBg: "Fondo",
      colorSurface: "Superficie",
      colorPrimary: "Acento",
      colorText: "Texto",
      colorSubtext: "Texto secundario",
      colorError: "Error",
      colorOnPrimary: "Texto sobre acento",
      font: "Fuente",
      fontHint: "Vacío usa la fuente del sistema",
      panels: "Paneles",
      showTopBar: "Barra superior",
      showInfoPanel: "Panel de información",
      showClock: "Reloj en el panel",
      showWeather: "Clima",
      showStats: "Uso del sistema",
      showSessionPanel: "Panel de sesión",
      showKeyboard: "Idioma y teclado",
      showPower: "Reiniciar y apagar",
      showUsers: "Lista de usuarios",
      showTagline: "Frase inferior",
      showFooter: "Marca inferior",
      showDots: "Indicadores de fondo",
      labelBubbles: "Globos detrás de los textos",
      bubbleOpacity: "Opacidad de los globos",
      sessionPanelExpanded: "Panel de sesión expandido al iniciar",
      clock24h: "Reloj de 24 horas",
      texts: "Textos",
      brand: "Nombre",
      subtitle: "Subtítulo",
      tagline: "Frase",
      footerBrand: "Marca inferior",
      language: "Idioma",
      langAuto: "Automático",
      remember: "Recordar",
      rememberUser: "Recordar el último usuario",
      rememberSession: "Recordar la última sesión",
      defaultSession: "Sesión por defecto",
      defaultSessionAuto: "Automática",
      weatherCity: "Ciudad",
      weatherCityHint: "Vacío oculta el clima",
      weatherF: "Usar Fahrenheit",
      syncTitle: "Conexión con OozeShell",
      syncHint: "Copia colores, fondo y foto de perfil de tu OozeShell para que el login coincida con tu escritorio.",
      syncNow: "Sincronizar ahora",
      syncRunning: "Sincronizando…",
      syncDone: "Sincronizado",
      syncFail: "Falló la sincronización",
      syncNoAvatar: "Sincronizado, pero no se encontró la foto de perfil",
      syncDetails: "Detalles",
      syncStatus: "Último fondo sincronizado",
      syncNever: "Todavía no se ha sincronizado",
      syncAvatar: "Foto de perfil",
      syncAvatarHint: "Se copia al greeter para tu usuario",
      useOozeColors: "Usar colores de OozeShell",
      useOozeWall: "Usar el fondo de OozeShell"
    },
    en: {
      session: "Session",
      langKeyboard: "Language / Keyboard",
      password: "Password",
      restart: "Restart",
      shutdown: "Shut down",
      sure: "Sure?",
      wrong: "Wrong password",
      authError: "Could not sign in",
      checking: "Checking…",
      starting: "Signing in…",
      capsOn: "Caps Lock is on",
      battery: "Battery",
      cpu: "CPU",
      ram: "RAM",
      gpu: "GPU",
      wxClear: "Clear",
      wxPartly: "Partly cloudy",
      wxCloudy: "Cloudy",
      wxFog: "Fog",
      wxDrizzle: "Drizzle",
      wxRain: "Rain",
      wxSnow: "Snow",
      wxStorm: "Thunderstorm",
      previewHint: "Preview: test password is “ooze”",
      kbLatam: "Spanish (Latin America)",
      kbEs: "Spanish (Spain)",
      kbUs: "English (US)",
      kbGb: "English (UK)",
      kbBr: "Portuguese (Brazil)",
      kbDe: "German",
      kbFr: "French",
      kbIt: "Italian",
      noSessions: "No sessions",
      user: "User",
      settingsTitle: "OozeLogin settings",
      navAppearance: "Appearance",
      navInterface: "Interface",
      navAccess: "Access",
      navWeather: "Weather",
      navOozeShell: "OozeShell",
      preview: "Preview",
      reload: "Reload",
      notWritable: "No write permission on {dir}. Make sure your user is in the configured group.",
      wallpaper: "Wallpaper",
      wallpaperHint: "Images stored in the greeter folder. Click to pick one.",
      wallpaperNone: "No images yet",
      addImage: "Add image",
      addImageHint: "Path of an image to copy into the greeter",
      add: "Add",
      wallpaperMode: "Wallpaper mode",
      modeFixed: "Fixed",
      modeRandom: "Random",
      modeSync: "OozeShell",
      bgBlur: "Background blur",
      bgDim: "Background dimming",
      panelBlur: "Blurred glass on panels",
      panelBlurHint: "Turn off on slow machines or virtual machines",
      panelOpacity: "Panel opacity",
      panelRadius: "Panel roundness",
      uiScale: "Interface scale",
      colors: "Colors",
      themeSource: "Theme source",
      themeCustom: "Custom",
      themeOoze: "OozeShell",
      colorBg: "Background",
      colorSurface: "Surface",
      colorPrimary: "Accent",
      colorText: "Text",
      colorSubtext: "Secondary text",
      colorError: "Error",
      colorOnPrimary: "Text on accent",
      font: "Font",
      fontHint: "Empty uses the system font",
      panels: "Panels",
      showTopBar: "Top bar",
      showInfoPanel: "Info panel",
      showClock: "Clock in the panel",
      showWeather: "Weather",
      showStats: "System usage",
      showSessionPanel: "Session panel",
      showKeyboard: "Language and keyboard",
      showPower: "Restart and shut down",
      showUsers: "User list",
      showTagline: "Bottom tagline",
      showFooter: "Bottom brand",
      showDots: "Wallpaper dots",
      labelBubbles: "Bubbles behind text",
      bubbleOpacity: "Bubble opacity",
      sessionPanelExpanded: "Session panel expanded at start",
      clock24h: "24-hour clock",
      texts: "Texts",
      brand: "Name",
      subtitle: "Subtitle",
      tagline: "Tagline",
      footerBrand: "Bottom brand",
      language: "Language",
      langAuto: "Automatic",
      remember: "Remember",
      rememberUser: "Remember the last user",
      rememberSession: "Remember the last session",
      defaultSession: "Default session",
      defaultSessionAuto: "Automatic",
      weatherCity: "City",
      weatherCityHint: "Empty hides the weather",
      weatherF: "Use Fahrenheit",
      syncTitle: "OozeShell connection",
      syncHint: "Copies colors, wallpaper and profile picture from your OozeShell so the login matches your desktop.",
      syncNow: "Sync now",
      syncRunning: "Syncing…",
      syncDone: "Synced",
      syncFail: "Sync failed",
      syncNoAvatar: "Synced, but no profile picture was found",
      syncDetails: "Details",
      syncStatus: "Last synced wallpaper",
      syncNever: "Nothing synced yet",
      syncAvatar: "Profile picture",
      syncAvatarHint: "Copied to the greeter for your user",
      useOozeColors: "Use OozeShell colors",
      useOozeWall: "Use the OozeShell wallpaper"
    }
  })

  readonly property var days: ({
    es: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
    en: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  })
  readonly property var months: ({
    es: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
    en: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  })

  function t(key) {
    const tab = root.tables[root.lang] || root.tables.en
    if (tab[key] !== undefined) return tab[key]
    const en = root.tables.en
    return en[key] !== undefined ? en[key] : key
  }

  function longDate(d) {
    const day = root.days[root.lang][d.getDay()]
    const mon = root.months[root.lang][d.getMonth()]
    return root.lang === "es" ? day + ", " + d.getDate() + " de " + mon : day + ", " + mon + " " + d.getDate()
  }

  function shortDate(d) {
    const mon = root.months[root.lang][d.getMonth()].slice(0, 3)
    const m = root.lang === "es" ? mon.toLowerCase() : mon
    return root.lang === "es" ? d.getDate() + " " + m + " " + d.getFullYear() : m + " " + d.getDate() + ", " + d.getFullYear()
  }

  function pad(n) { return n < 10 ? "0" + n : String(n) }

  function time(d, h24) {
    if (h24) return root.pad(d.getHours()) + ":" + root.pad(d.getMinutes())
    const h = d.getHours() % 12 === 0 ? 12 : d.getHours() % 12
    return root.pad(h) + ":" + root.pad(d.getMinutes())
  }

  function layoutName(code) {
    const base = String(code).split("(")[0].trim()
    const map = { latam: "kbLatam", es: "kbEs", us: "kbUs", gb: "kbGb", br: "kbBr", de: "kbDe", fr: "kbFr", it: "kbIt" }
    return map[base] ? root.t(map[base]) : String(code).toUpperCase()
  }
}
