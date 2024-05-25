const std = @import("std");
const rl = @import("raylib");
const menu = @import("menu.zig");

var exit = false;
fn windowShouldClose() bool {
    return rl.windowShouldClose() or exit;
}

// gameStatus and UI.xMenu.active seems redundant..
var gameStatus: union(enum) {
    mainMenu,
    play,
    paused,
} = .mainMenu;

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    var mainMenu = menu.MainMenu{ .active = true };
    var pauseMenu = menu.PauseMenu{ .active = false };

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    // Main game loop
    while (!windowShouldClose()) {
        switch (gameStatus) {
            .mainMenu => {
                switch (mainMenu.update()) {
                    .nothing => {},
                    .play => {
                        gameStatus = .play;
                        std.debug.print("playing..\n", .{});
                    },
                    .exit => {
                        exit = true;
                    },
                }
            },
            .play => {
                if (rl.isKeyPressed(.key_escape)) {
                    pauseMenu.active = true;
                    gameStatus = .paused;
                }
            },
            .paused => {
                const pauseStatus = if (rl.isKeyPressed(.key_escape))
                    .play
                else
                    pauseMenu.update();

                switch (pauseStatus) {
                    .nothing => {},
                    .play => {
                        // This is redundant when we go back due to clicking, but needed when pressing escape
                        pauseMenu.active = false;
                        gameStatus = .play;
                    },
                    .menu => {
                        mainMenu.active = true;
                        gameStatus = .mainMenu;
                    },
                    .exit => {
                        exit = true;
                    },
                }
            },
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        mainMenu.draw();
        pauseMenu.draw();
        // This logic will be done inside gameState.draw()
        switch (gameStatus) {
            .play => {
                rl.drawText("Intensive gameplay!!", 30, 200, 50, rl.Color.red);
            },
            .mainMenu => {},
            .paused => {},
        }
    }
}
