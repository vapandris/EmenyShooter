const std = @import("std");
const rl = @import("raylib");
const menu = @import("menu.zig");
const gameState = @import("gameState.zig");

var exit = false;
fn windowShouldClose() bool {
    return rl.windowShouldClose() or exit;
}

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    var mainMenu = menu.MainMenu{};
    var pauseMenu = menu.PauseMenu{};

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    gameState.game = gameState.GameState.init();
    defer gameState.game.deinit();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    // Main game loop
    while (!windowShouldClose()) {
        switch (gameState.gameStatus) {
            .mainMenu => {
                switch (mainMenu.update()) {
                    .nothing => {},
                    .play => {
                        gameState.gameStatus = .play;
                        gameState.game.reset();
                    },
                    .exit => {
                        exit = true;
                    },
                }
            },
            .play => {
                if (rl.isKeyPressed(.key_escape)) {
                    gameState.gameStatus = .paused;
                }

                gameState.game.update();
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
                        gameState.gameStatus = .play;
                    },
                    .menu => {
                        gameState.gameStatus = .mainMenu;
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
        gameState.game.draw();
        mainMenu.draw();
        pauseMenu.draw();
    }
}
