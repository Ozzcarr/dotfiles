// Recolors the theme to the wallpaper accent from ~/.cache/oz-accent.json,
// written by the Quickshell config. Every root custom property whose value is
// the theme's accent (`replace`) is overridden, keeping its alpha.

const ACCENT_FILE = PathUtils.join(Services.dirsvc.get("Home", Ci.nsIFile).path, ".cache", "oz-accent.json");
const POLL_MS = 2000;

let current = null; // { replace, accent, accentAlt } once read
let lastModified = 0;

// Per window: property name -> original alpha. Never cleared, because
// lightweight-theme-styling-update fires often and a rescan then only sees
// our own overrides.
const painted = new WeakMap();

// "#rrggbb", "rgb(r, g, b)" or "rgba(r, g, b, a)" -> { r, g, b, a }, else null.
function parseColor(value) {
  const v = value.trim().toLowerCase();

  const hex = /^#([0-9a-f]{6})([0-9a-f]{2})?$/.exec(v);
  if (hex) {
    const n = parseInt(hex[1], 16);
    return {
      r: (n >> 16) & 255,
      g: (n >> 8) & 255,
      b: n & 255,
      a: hex[2] ? parseInt(hex[2], 16) / 255 : 1,
    };
  }

  const rgb = /^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$/.exec(v);
  if (rgb) {
    return { r: +rgb[1], g: +rgb[2], b: +rgb[3], a: rgb[4] === undefined ? 1 : +rgb[4] };
  }

  return null;
}

function sameRgb(a, b) {
  return a.r === b.r && a.g === b.g && a.b === b.b;
}

function scan(win, replace) {
  const style = win.document.documentElement.style;
  const target = parseColor(replace);
  let found = painted.get(win);
  if (!found) {
    found = new Map();
    painted.set(win, found);
  }

  for (let i = 0; i < style.length; i++) {
    const name = style.item(i);
    if (!name.startsWith("--") || style.getPropertyPriority(name) === "important") {
      continue;
    }
    const color = parseColor(style.getPropertyValue(name));
    if (color && target && sameRgb(color, target)) {
      found.set(name, color.a);
    }
  }

  return found;
}

function apply(win) {
  if (!current) {
    return;
  }

  const accent = parseColor(current.accent);
  if (!accent) {
    return;
  }

  const style = win.document.documentElement.style;
  const targets = scan(win, current.replace);

  for (const [name, alpha] of targets) {
    style.setProperty(name, `rgba(${accent.r}, ${accent.g}, ${accent.b}, ${alpha})`, "important");
  }
}

function browserWindows() {
  const windows = [];
  const e = Services.wm.getEnumerator("navigator:browser");
  while (e.hasMoreElements()) {
    windows.push(e.getNext());
  }
  return windows;
}

async function poll() {
  try {
    const info = await IOUtils.stat(ACCENT_FILE);
    if (info.lastModified !== lastModified) {
      lastModified = info.lastModified;
      current = await IOUtils.readJSON(ACCENT_FILE);
      for (const win of browserWindows()) {
        apply(win);
      }
    }
  } catch (e) {
    // No accent file yet.
  }
}

Services.obs.addObserver(() => {
  for (const win of browserWindows()) {
    // The theme applies its styles after notifying.
    win.requestAnimationFrame(() => apply(win));
  }
}, "lightweight-theme-styling-update");

Services.obs.addObserver((win) => apply(win), "browser-delayed-startup-finished");

poll();
const timer = Cc["@mozilla.org/timer;1"].createInstance(Ci.nsITimer);
timer.initWithCallback({ notify: poll }, POLL_MS, Ci.nsITimer.TYPE_REPEATING_SLACK);
