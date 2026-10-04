// One launcher mode. `results` is a binding over Launcher.query; each result
// is an object with:
//   key       stable id, used for selection and confirmation
//   title     main line
//   subtitle  second line (optional)
//   icon      theme icon name, or glyph: a Material Symbols name (optional)
//   hint      right-aligned text, like a key combo (optional)
//   confirm   needs a second Enter (optional)
//   keepOpen  the launcher stays open after it runs (optional)
//   run(alt)  what Enter does; alt is true with Shift held
import Quickshell

Scope {
    required property string name
    required property string label
    required property string icon
    required property string placeholder

    // Typed into an empty search to switch here; "" for the default mode.
    property string prefix: ""
    // Shown in the search field's list of prefixes.
    property string short: ""
    // Shown instead of results when the search is empty.
    property string emptyHint: "Nothing here yet"

    property var results: []

    // Emitted when the launcher switches to this mode.
    signal opened
}
