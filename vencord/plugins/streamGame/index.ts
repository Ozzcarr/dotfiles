/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { Logger } from "@utils/Logger";
import definePlugin, { PluginNative } from "@utils/types";
import { findByCodeLazy } from "@webpack";
import { ApplicationStreamingStore, ChannelStore, MediaEngineStore, SelectedChannelStore, showToast } from "@webpack/common";

const Native = VencordNative.pluginHelpers.StreamGame as PluginNative<typeof import("./native")>;

const logger = new Logger("StreamGame");

// Discord's own Go Live action creators.
const startStream = findByCodeLazy('type:"STREAM_START"');
const stopStream = findByCodeLazy('type:"STREAM_STOP"');

// Vesktop's venmic bridge. Its virtual mic is attached to any stream started while it runs.
declare const VesktopNative: {
    virtmic: {
        start(include: Record<string, string>[]): Promise<void>;
        stop(): Promise<void>;
    };
};

// The web engine's signature: capture size and whether to take audio, resolving to the
// id startStream wants. The shared typings only describe the native engine's.
interface WebMediaEngine {
    getDesktopSource(size: { width: number; height: number; }, audio: boolean): Promise<string>;
}

interface Game {
    title: string;
    pids: number[];
}

interface Stream {
    streamType: string;
    guildId: string | null;
    channelId: string;
    ownerId: string;
}

function streamKey({ streamType, guildId, channelId, ownerId }: Stream) {
    return (guildId != null ? [streamType, guildId, channelId, ownerId] : [streamType, channelId, ownerId]).join(":");
}

// Vesktop asks for quality and audio in its own modal before the stream starts. Both are
// already settled by then (quality from its saved settings, audio from the virtual mic),
// so the modal only needs confirming.
function confirmPicker() {
    const findButton = () => [...document.querySelectorAll<HTMLButtonElement>('[role="dialog"] button')]
        .find(b => b.textContent === "Go Live" && b.closest('[role="dialog"]')?.textContent?.includes("Screen Share Picker"));

    return new Promise<void>((resolve, reject) => {
        const observer = new MutationObserver(() => {
            const button = findButton();
            if (!button) return;
            observer.disconnect();
            clearTimeout(timeout);
            button.click();
            resolve();
        });
        const timeout = setTimeout(() => {
            observer.disconnect();
            reject(new Error("Vesktop's stream picker never opened"));
        }, 30_000);

        observer.observe(document.body, { childList: true, subtree: true });
    });
}

async function start(game: Game, channelId: string) {
    const channel = ChannelStore.getChannel(channelId);

    // Venmic matches each entry on its own, so this takes any of the game's processes.
    await VesktopNative.virtmic.start(game.pids.map(pid => ({ "application.process.id": String(pid) })));

    const confirmed = confirmPicker();
    try {
        // The same two steps Discord's web Go Live button takes; the window is chosen by
        // xdph's picker, which vesktop-stream has already told which one.
        const engine = MediaEngineStore.getMediaEngine() as unknown as WebMediaEngine;
        const sourceId = await engine.getDesktopSource({ width: 1920, height: 1080 }, true);
        startStream(channel?.guild_id ?? null, channelId, { pid: null, sourceId, sourceName: null });
        await confirmed;
    } catch (err) {
        confirmed.catch(() => { });
        await VesktopNative.virtmic.stop();
        throw err;
    }

    showToast(`Streaming ${game.title}`, "success");
}

export default definePlugin({
    name: "StreamGame",
    description: "Toggles a Go Live of the running game, with only its audio, when vesktop-stream is run.",
    authors: [{ name: "Me", id: 0n }],

    start() {
        Native.listen();
    },

    stop() {
        Native.close();
    },

    // Called by native.ts. Answers right away so vesktop-stream knows whether its
    // window pick is about to be used; the stream itself starts in the background.
    toggle(game: Game): "starting" | "stopped" | "idle" {
        const active = ApplicationStreamingStore.getCurrentUserActiveStream() as Stream | null;
        if (active) {
            stopStream(streamKey(active));
            return "stopped";
        }

        const channelId = SelectedChannelStore.getVoiceChannelId();
        if (!channelId) {
            showToast("Join a voice channel to stream", "failure");
            return "idle";
        }

        start(game, channelId).catch(err => {
            logger.error("Failed to start the stream", err);
            showToast("Couldn't start the stream", "failure");
        });
        return "starting";
    }
});
