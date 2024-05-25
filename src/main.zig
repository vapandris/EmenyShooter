const std = @import("std");
const rl = @import("raylib");
const menu = @import("menu.zig");

var exit = false;
fn windowShouldClose() bool {
    return rl.windowShouldClose() or exit;
}

var gameStatus: union(enum) {
    mainMenu,
    play,
} = .mainMenu;

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    var mainMenu = menu.MainMenu{ .active = true };

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
                // Update game state
            },
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        mainMenu.draw();
        // This logic will be done inside gameState.draw()
        switch (gameStatus) {
            .play => {
                rl.drawText("Intensive gameplay!!", 30, 200, 50, rl.Color.red);
            },
            .mainMenu => {},
        }
    }
}
