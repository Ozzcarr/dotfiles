// Ctrl+Shift+H toggles the tab bar/nav bar on just the focused window, via an
// attribute userChrome.css keys off of.
//
// This intercepts the raw keydown in the capturing phase instead of using
// fx-autoconfig's Hotkey.autoAttach({suppressOriginal}), which disables
// Firefox's built-in History key by querying for it once a window finishes
// its delayed startup. That query loses a race in freshly-opened windows
// (the built-in key isn't always in the DOM yet at that point), so the
// History binding stayed live there -- it only ever worked reliably in
// whichever window was open first. Capturing keydown ourselves and calling
// stopImmediatePropagation() sidesteps that race entirely: it doesn't matter
// when/whether Firefox's own key element exists, ours simply runs first.
//
// Attaches via Services.wm/Services.obs directly rather than fx-autoconfig's
// Windows.getAll()/onCreated() wrapper (from uc_api.sys.mjs): that wrapper's
// registration silently no-ops when called from this module's top-level
// scope specifically (confirmed by hand -- the identical addEventListener
// call works when run directly against a window, and Windows.onCreated
// itself fires fine when registered from a plain script, just not from here).
function onKeyDown(win, event) {
  if (
    event.ctrlKey &&
    event.shiftKey &&
    !event.altKey &&
    !event.metaKey &&
    event.key.toLowerCase() === "h"
  ) {
    event.preventDefault();
    event.stopImmediatePropagation();
    win.document.documentElement.toggleAttribute("uc-chrome-hidden");
  }
}

function attach(win) {
  win.addEventListener("keydown", (event) => onKeyDown(win, event), true);
}

function isBrowserWindow(win) {
  return win.document.documentElement.getAttribute("windowtype") === "navigator:browser";
}

const winEnum = Services.wm.getEnumerator("navigator:browser");
while (winEnum.hasMoreElements()) {
  attach(winEnum.getNext());
}

Services.obs.addObserver(function observe(subject) {
  subject.addEventListener(
    "DOMContentLoaded",
    () => {
      if (isBrowserWindow(subject)) {
        attach(subject);
      }
    },
    { once: true }
  );
}, "domwindowopened");
