import { definePluginSettings } from "@api/Settings";
import definePlugin, { OptionType } from "@utils/types";
import { FluxDispatcher } from "@webpack/common";

type Mode = "normal" | "insert" | "hint";
type Pane = "guilds" | "channels" | "chat" | "members";

const PANES: Pane[] = ["guilds", "channels", "chat", "members"];

const settings = definePluginSettings({
    showIndicator: {
        type: OptionType.BOOLEAN,
        description: "Show the mode indicator",
        default: true
    },
    indicatorPosition: {
        type: OptionType.SELECT,
        description: "Where to anchor the mode indicator",
        options: [
            { label: "Top left", value: "top-left" },
            { label: "Top right", value: "top-right", default: true },
            { label: "Bottom left (overlaps the user panel)", value: "bottom-left" },
            { label: "Bottom right", value: "bottom-right" }
        ]
    },
    scrollStep: {
        type: OptionType.NUMBER,
        description: "Pixels scrolled per j/k press in the chat pane",
        default: 80
    },
    smoothScroll: {
        type: OptionType.BOOLEAN,
        description: "Animate scrolling (off feels more terminal-like)",
        default: false
    },
    hintChars: {
        type: OptionType.STRING,
        description: "Characters used to build hint labels in f mode",
        default: "asdfghjkl"
    },
    debug: {
        type: OptionType.BOOLEAN,
        description: "Log selector misses to the console",
        default: false
    }
});

/* ---------------------------------------------------------------- state -- */

let mode: Mode = "normal";
let pane: Pane = "chat";
let countBuffer = "";
let pendingG = false;
let pendingGTimer: number | undefined;

let indicator: HTMLElement | null = null;
let styleEl: HTMLStyleElement | null = null;
let hintLayer: HTMLElement | null = null;
let hints: { label: string; el: HTMLElement; chip: HTMLElement; }[] = [];
let hintBuffer = "";

/* --------------------------------------------------------------- styles -- */

const CSS = `
.vimnav-indicator {
    position: fixed;
    z-index: 10000;
    display: flex;
    gap: 0.75ch;
    padding: 2px 8px;
    pointer-events: none;
    user-select: none;
    font-family: var(--font, 'DM Mono'), monospace;
    font-size: 12px;
    letter-spacing: -0.05ch;
    line-height: 1.6;
    background: var(--bg-3, #181825);
    border: var(--border-thickness, 2px) solid var(--border, hsla(235, 15%, 53%, 0.2));
    color: var(--text-3, #bac2de);
}
.vimnav-indicator[data-pos="top-left"]     { top: var(--gap, 12px); left: var(--gap, 12px); }
.vimnav-indicator[data-pos="top-right"]    { top: var(--gap, 12px); right: var(--gap, 12px); }
.vimnav-indicator[data-pos="bottom-left"]  { bottom: var(--gap, 12px); left: var(--gap, 12px); }
.vimnav-indicator[data-pos="bottom-right"] { bottom: var(--gap, 12px); right: var(--gap, 12px); }

.vimnav-indicator .vimnav-mode { font-weight: 500; }
/* nvim-ish: blue normal, green insert, yellow pending/hint */
.vimnav-indicator[data-mode="normal"] .vimnav-mode { color: var(--blue-2, #89b4fa); }
.vimnav-indicator[data-mode="insert"] .vimnav-mode { color: var(--green-2, #a6e3a1); }
.vimnav-indicator[data-mode="hint"]   .vimnav-mode { color: var(--yellow-2, #f9e2af); }
.vimnav-indicator .vimnav-pane { color: var(--text-5, #585b70); }

.vimnav-hint-layer {
    position: fixed;
    inset: 0;
    z-index: 10001;
    pointer-events: none;
}
.vimnav-hint {
    position: absolute;
    padding: 0 4px;
    font-family: var(--font, 'DM Mono'), monospace;
    font-size: 11px;
    line-height: 1.5;
    text-transform: lowercase;
    background: var(--bg-3, #181825);
    border: 1px solid var(--yellow-2, #f9e2af);
    color: var(--yellow-2, #f9e2af);
    white-space: nowrap;
}
.vimnav-hint .vimnav-hint-typed { color: var(--text-5, #585b70); }
`;

/* -------------------------------------------------------------- helpers -- */

function warn(...args: unknown[]) {
    if (settings.store.debug) console.warn("[vimNav]", ...args);
}

function isEditable(el: Element | null): boolean {
    if (!(el instanceof HTMLElement)) return false;
    if (el.isContentEditable) return true;
    const tag = el.tagName;
    return tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT";
}

function isScrollable(el: HTMLElement): boolean {
    if (el.scrollHeight <= el.clientHeight) return false;
    return /auto|scroll/.test(getComputedStyle(el).overflowY);
}

function visible(el: HTMLElement): boolean {
    return el.offsetParent !== null && el.getBoundingClientRect().height > 0;
}

/** First selector that matches something, so a Discord DOM shuffle degrades instead of dying. */
function pick(...selectors: string[]): HTMLElement | null {
    for (const selector of selectors) {
        const el = document.querySelector<HTMLElement>(selector);
        if (el) return el;
    }
    warn("no match for any of", selectors);
    return null;
}

function getChatScroller(): HTMLElement | null {
    const list = document.querySelector<HTMLElement>('ol[data-list-id="chat-messages"]');
    let el = list?.parentElement ?? null;
    while (el && !isScrollable(el)) el = el.parentElement;
    return el ?? pick('[class*="messagesWrapper"] [class*="scroller"]');
}

function getTextbox(): HTMLElement | null {
    return pick('div[role="textbox"][data-slate-editor="true"]', 'div[role="textbox"]');
}

function getGuildList(): HTMLElement | null {
    return pick('[data-list-id="guildsnav"]', 'nav[aria-label] [class*="scroller"]');
}

function getChannelList(): HTMLElement | null {
    return pick('[data-list-id="channels"]', '[data-list-id="private-channels"]');
}

function getMemberList(): HTMLElement | null {
    return pick('[data-list-id^="members"]', '[class*="memberList"]');
}

/**
 * Clicking the real anchor is what actually navigates. The earlier version drove
 * NavigationRouter directly and fell back to assigning window.location, which in
 * Electron reloads the whole client instead of routing.
 */
function activate(el: HTMLElement) {
    const target = el.matches('a[href], [role="button"], [role="treeitem"]')
        ? el
        : el.querySelector<HTMLElement>('a[href], [role="button"], [role="treeitem"]') ?? el;

    const opts = { bubbles: true, cancelable: true, view: window };
    target.dispatchEvent(new PointerEvent("pointerdown", opts));
    target.dispatchEvent(new MouseEvent("mousedown", opts));
    target.dispatchEvent(new PointerEvent("pointerup", opts));
    target.dispatchEvent(new MouseEvent("mouseup", opts));
    target.click();
}

/* ---------------------------------------------------------- pane contents -- */

function itemsFor(p: Pane): HTMLElement[] {
    switch (p) {
        case "guilds": {
            const nav = getGuildList();
            if (!nav) return [];
            const items = [...nav.querySelectorAll<HTMLElement>('[data-list-item-id^="guildsnav___"]')];
            return (items.length ? items : [...nav.querySelectorAll<HTMLElement>('a[href^="/channels/"]')])
                .filter(visible);
        }
        case "channels": {
            const list = getChannelList();
            if (!list) return [];
            return [...list.querySelectorAll<HTMLElement>('a[href^="/channels/"]')].filter(visible);
        }
        case "members": {
            const list = getMemberList();
            if (!list) return [];
            return [...list.querySelectorAll<HTMLElement>('[class*="member_"], [role="listitem"]')]
                .filter(visible);
        }
        case "chat":
            return [];
    }
}

/** Index of the item Discord itself considers current, so j/k continue from the real position. */
function currentIndex(p: Pane, items: HTMLElement[]): number {
    if (p === "guilds" || p === "channels") {
        const path = location.pathname;
        const index = items.findIndex(el => {
            const href = el.matches("a[href]")
                ? el.getAttribute("href")
                : el.querySelector("a[href]")?.getAttribute("href");
            return href ? path.startsWith(href) : false;
        });
        if (index !== -1) return index;
    }
    return items.findIndex(el => el.contains(document.activeElement));
}

function step(p: Pane, delta: number) {
    const items = itemsFor(p);
    if (!items.length) {
        warn(`no items in pane "${p}"`);
        return;
    }
    const from = currentIndex(p, items);
    const base = from === -1 ? (delta > 0 ? -1 : 0) : from;
    const next = items[(base + delta + items.length) % items.length];

    next.scrollIntoView({ block: "nearest" });

    // Focus so the theme's own focus styling tracks the cursor. Members aren't
    // links, so nothing navigates on focus alone -- Enter activates.
    if (p === "members") {
        if (!next.hasAttribute("tabindex")) next.tabIndex = -1;
        next.focus({ preventScroll: true });
    } else {
        activate(next);
    }
}

/* --------------------------------------------------------------- motion -- */

function scrollChat(amount: number) {
    const scroller = getChatScroller();
    if (!scroller) return;
    scroller.scrollBy({ top: amount, behavior: settings.store.smoothScroll ? "smooth" : "auto" });
}

function scrollChatTo(where: "top" | "bottom") {
    const scroller = getChatScroller();
    if (!scroller) return;
    scroller.scrollTo({
        top: where === "top" ? 0 : scroller.scrollHeight,
        behavior: settings.store.smoothScroll ? "smooth" : "auto"
    });
}

function move(delta: number) {
    const count = Math.max(1, parseInt(countBuffer || "1", 10));
    countBuffer = "";
    if (pane === "chat") return scrollChat(delta * settings.store.scrollStep * count);
    for (let i = 0; i < count; i++) step(pane, delta);
}

function movePane(delta: number) {
    const index = PANES.indexOf(pane);
    setPane(PANES[Math.min(PANES.length - 1, Math.max(0, index + delta))]);
}

function enterInsert() {
    const box = getTextbox();
    if (!box) return;
    box.focus();
    setMode("insert");
}

function openQuickSwitcher() {
    FluxDispatcher.dispatch({ type: "QUICKSWITCHER_SHOW", query: "", queryMode: null });
}

/* ---------------------------------------------------------------- modes -- */

function setMode(next: Mode) {
    if (mode === next) return;
    if (mode === "hint" && next !== "hint") clearHints();
    mode = next;
    document.body.dataset.vimMode = next;
    renderIndicator();
}

function setPane(next: Pane) {
    pane = next;
    document.body.dataset.vimPane = next;
    // Put the cursor somewhere real in the new pane so the theme highlights it.
    if (next !== "chat") {
        const items = itemsFor(next);
        const index = currentIndex(next, items);
        if (index !== -1) items[index].scrollIntoView({ block: "nearest" });
    }
    renderIndicator();
}

function renderIndicator() {
    if (!indicator) return;
    indicator.style.display = settings.store.showIndicator ? "flex" : "none";
    indicator.dataset.mode = mode;
    indicator.dataset.pos = settings.store.indicatorPosition;
    const extra = mode === "hint" ? hintBuffer : countBuffer + (pendingG ? "g" : "");
    indicator.innerHTML = "";

    const m = document.createElement("span");
    m.className = "vimnav-mode";
    m.textContent = `-- ${mode.toUpperCase()} --`;

    const p = document.createElement("span");
    p.className = "vimnav-pane";
    p.textContent = extra ? `${pane} ${extra}` : pane;

    indicator.append(m, p);
}

/* ---------------------------------------------------------------- hints -- */

const HINT_SELECTOR = [
    "a[href]",
    "button",
    "input",
    "textarea",
    "[role='button']",
    "[role='treeitem']",
    "[role='tab']",
    "[role='menuitem']",
    "[role='checkbox']",
    "[role='link']"
].join(",");

function makeLabels(count: number): string[] {
    const chars = [...new Set(settings.store.hintChars.replace(/\s/g, ""))];
    if (chars.length < 2) return [];
    if (count <= chars.length) return chars.slice(0, count);

    const labels: string[] = [];
    outer: for (const a of chars) {
        for (const b of chars) {
            labels.push(a + b);
            if (labels.length >= count) break outer;
        }
    }
    return labels;
}

function showHints() {
    clearHints();

    const candidates = [...document.querySelectorAll<HTMLElement>(HINT_SELECTOR)].filter(el => {
        if (el.closest(".vimnav-hint-layer")) return false;
        if ((el as HTMLButtonElement).disabled) return false;
        const r = el.getBoundingClientRect();
        if (r.width < 4 || r.height < 4) return false;
        if (r.bottom < 0 || r.top > innerHeight || r.right < 0 || r.left > innerWidth) return false;
        const cs = getComputedStyle(el);
        return cs.visibility !== "hidden" && cs.display !== "none" && cs.opacity !== "0";
    });

    const labels = makeLabels(candidates.length);
    if (!labels.length) return;

    hintLayer = document.createElement("div");
    hintLayer.className = "vimnav-hint-layer";
    document.body.append(hintLayer);

    hints = candidates.slice(0, labels.length).map((el, i) => {
        const r = el.getBoundingClientRect();
        const chip = document.createElement("div");
        chip.className = "vimnav-hint";
        chip.textContent = labels[i];
        chip.style.left = `${Math.max(0, r.left)}px`;
        chip.style.top = `${Math.max(0, r.top)}px`;
        hintLayer!.append(chip);
        return { label: labels[i], el, chip };
    });

    hintBuffer = "";
    setMode("hint");
}

function filterHints() {
    let matches = 0;
    let exact: typeof hints[0] | undefined;

    for (const hint of hints) {
        const isMatch = hint.label.startsWith(hintBuffer);
        hint.chip.style.display = isMatch ? "block" : "none";
        if (!isMatch) continue;
        matches++;
        if (hint.label === hintBuffer) exact = hint;
        hint.chip.innerHTML = `<span class="vimnav-hint-typed">${hintBuffer}</span>${hint.label.slice(hintBuffer.length)}`;
    }

    if (exact && matches === 1) {
        const target = exact.el;
        setMode("normal");
        if (isEditable(target)) {
            target.focus();
            setMode("insert");
        } else {
            activate(target);
        }
        return;
    }
    if (matches === 0) setMode("normal");
    renderIndicator();
}

function clearHints() {
    hintLayer?.remove();
    hintLayer = null;
    hints = [];
    hintBuffer = "";
}

/* ---------------------------------------------------------- key handling -- */

function stop(e: KeyboardEvent) {
    e.preventDefault();
    e.stopPropagation();
}

function onKeyDown(e: KeyboardEvent) {
    if (mode === "hint") {
        if (e.key === "Escape") { stop(e); setMode("normal"); return; }
        if (e.key === "Backspace") { stop(e); hintBuffer = hintBuffer.slice(0, -1); filterHints(); return; }
        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
            stop(e);
            hintBuffer += e.key.toLowerCase();
            filterHints();
        }
        return;
    }

    // Anything typed into a real input belongs to that input.
    if (isEditable(document.activeElement)) {
        if (e.key === "Escape") {
            (document.activeElement as HTMLElement).blur();
            setMode("normal");
        }
        return;
    }

    if (mode === "insert") { setMode("normal"); return; }

    if (e.ctrlKey || e.metaKey) {
        const scroller = getChatScroller();
        if (e.key === "d" && scroller) { stop(e); scrollChat(scroller.clientHeight / 2); }
        else if (e.key === "u" && scroller) { stop(e); scrollChat(-scroller.clientHeight / 2); }
        return;
    }
    if (e.altKey) return; // leave Discord's own alt bindings alone

    if (pendingG) {
        clearTimeout(pendingGTimer);
        pendingG = false;
        if (e.key === "g") { stop(e); scrollChatTo("top"); renderIndicator(); return; }
        renderIndicator();
    }

    if (/^[1-9]$/.test(e.key) || (e.key === "0" && countBuffer)) {
        stop(e);
        countBuffer += e.key;
        renderIndicator();
        return;
    }

    switch (e.key) {
        case "j": stop(e); move(1); break;
        case "k": stop(e); move(-1); break;
        case "h": stop(e); movePane(-1); break;
        case "l": stop(e); movePane(1); break;
        case "J": stop(e); step("channels", 1); break;
        case "K": stop(e); step("channels", -1); break;
        case "L": stop(e); step("guilds", 1); break;
        case "H": stop(e); step("guilds", -1); break;
        case "g": stop(e); pendingG = true; pendingGTimer = window.setTimeout(() => { pendingG = false; renderIndicator(); }, 700); renderIndicator(); break;
        case "G": stop(e); scrollChatTo("bottom"); break;
        case "o":
        case "Enter": {
            stop(e);
            const active = document.activeElement;
            if (pane !== "chat" && active instanceof HTMLElement && active !== document.body) activate(active);
            else enterInsert();
            break;
        }
        case "i":
        case "a": stop(e); enterInsert(); break;
        case "f": stop(e); showHints(); break;
        case "t":
        case "/": stop(e); openQuickSwitcher(); break;
        case "Escape": setPane("chat"); countBuffer = ""; renderIndicator(); break;
        default: countBuffer = ""; renderIndicator();
    }
}

function onFocusIn(e: FocusEvent) {
    if (isEditable(e.target as Element)) setMode("insert");
}

function onFocusOut() {
    setTimeout(() => {
        if (mode === "insert" && !isEditable(document.activeElement)) setMode("normal");
    }, 0);
}

/* --------------------------------------------------------------- plugin -- */

export default definePlugin({
    name: "VimNavigation",
    description: "Modal vim-style navigation for Discord: hjkl pane movement, j/k scrolling and channel switching, f-mode link hints, and i/Esc insert mode.",
    authors: [{ name: "oscar", id: 0n }],
    settings,

    start() {
        styleEl = document.createElement("style");
        styleEl.id = "vimnav-styles";
        styleEl.textContent = CSS;
        document.head.append(styleEl);

        indicator = document.createElement("div");
        indicator.className = "vimnav-indicator";
        document.body.append(indicator);

        document.addEventListener("keydown", onKeyDown, true);
        document.addEventListener("focusin", onFocusIn, true);
        document.addEventListener("focusout", onFocusOut, true);

        setMode("normal");
        setPane("chat");
        renderIndicator();
    },

    stop() {
        document.removeEventListener("keydown", onKeyDown, true);
        document.removeEventListener("focusin", onFocusIn, true);
        document.removeEventListener("focusout", onFocusOut, true);

        clearTimeout(pendingGTimer);
        clearHints();

        indicator?.remove();
        indicator = null;
        styleEl?.remove();
        styleEl = null;

        delete document.body.dataset.vimMode;
        delete document.body.dataset.vimPane;
    }
});
