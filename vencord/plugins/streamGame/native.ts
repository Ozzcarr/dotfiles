/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { IpcMainInvokeEvent } from "electron";
import { rmSync } from "fs";
import { createServer, Server } from "net";
import { join } from "path";

// vesktop-stream writes one JSON line here and reads back what the renderer did.
const socketPath = join(process.env.XDG_RUNTIME_DIR ?? "/tmp", "vesktop-stream.sock");

let server: Server | null = null;

export function listen(e: IpcMainInvokeEvent) {
    close();

    // Half-open, because socat shuts its write side as soon as it has sent the line.
    server = createServer({ allowHalfOpen: true }, conn => {
        let data = "";
        conn.on("data", chunk => {
            data += chunk;
            const end = data.indexOf("\n");
            if (end < 0) return;

            let game: unknown;
            try {
                game = JSON.parse(data.slice(0, end));
            } catch {
                conn.end("error\n");
                return;
            }

            // Re-serialised, so only a JSON literal ever reaches the renderer.
            e.sender.executeJavaScript(`Vencord.Plugins.plugins.StreamGame.toggle(${JSON.stringify(game)})`)
                .then(reply => conn.end(`${reply}\n`), () => conn.end("error\n"));
        });
    });

    server.listen(socketPath);
}

// Signal 0 only checks the process exists; EPERM still means it does.
export function anyAlive(_: IpcMainInvokeEvent, pids: number[]) {
    return pids.some(pid => {
        try {
            process.kill(pid, 0);
            return true;
        } catch (err) {
            return (err as NodeJS.ErrnoException).code === "EPERM";
        }
    });
}

export function close() {
    server?.close();
    server = null;
    rmSync(socketPath, { force: true });
}
