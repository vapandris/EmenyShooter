const UI = @import("UI.zig");
const rl = @import("raylib");

// probably a bad idea to import main.. anyhow:
const gameState = @import("gameState.zig");

pub const MainMenu = struct {
    playBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 160 }, .{ .w = 200, .h = 50 }, 30),
    exitBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 230 }, .{ .w = 200, .h = 50 }, 30),

    const text: [:0]const u8 = "Main Menu";

    pub fn draw(self: MainMenu) void {
        if (gameState.gameStatus == .mainMenu) {
            rl.drawText(
                MainMenu.text,
                self.playBtn.pos.x + self.playBtn.borderThickness,
                self.playBtn.pos.y - self.playBtn.size.h,
                40,
                UI.green,
            );

            self.playBtn.draw("Play");
            self.exitBtn.draw("Exit");
        }
    }

    pub fn update(self: *MainMenu) enum { play, exit, nothing } {
        if (gameState.gameStatus == .mainMenu) {
            if (self.*.playBtn.update() == .released) {
                return .play;
            } else if (self.*.exitBtn.update() == .released) {
                return .exit;
            }
        }

        return .nothing;
    }
};

pub const PauseMenu = struct {
    continueBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 100 }, .{ .w = 200, .h = 50 }, 30),
    mainMenuBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 160 }, .{ .w = 200, .h = 50 }, 30),
    exitBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 220 }, .{ .w = 200, .h = 50 }, 30),
    const text: [:0]const u8 = "Pasued";

    pub fn draw(self: PauseMenu) void {
        if (gameState.gameStatus == .paused) {
            rl.drawText(
                PauseMenu.text,
                self.continueBtn.pos.x + self.continueBtn.borderThickness,
                self.continueBtn.pos.y - self.continueBtn.size.h,
                30,
                UI.green,
            );

            self.continueBtn.draw("Continue");
            self.mainMenuBtn.draw("Main Menu");
            self.exitBtn.draw("Exit");
        }
    }

    pub fn update(self: *PauseMenu) enum { play, menu, exit, nothing } {
        if (gameState.gameStatus == .paused) {
            if (self.*.continueBtn.update() == .released) {
                return .play;
            } else if (self.*.mainMenuBtn.update() == .released) {
                return .menu;
            } else if (self.*.exitBtn.update() == .released) {
                return .exit;
            }
        }

        return .nothing;
    }
};
