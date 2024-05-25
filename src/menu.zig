const UI = @import("UI.zig");
const rl = @import("raylib");

pub const MainMenu = struct {
    active: bool,
    playBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 160 }, .{ .w = 200, .h = 50 }, 30),
    exitBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 230 }, .{ .w = 200, .h = 50 }, 30),

    const text: [:0]const u8 = "Main Menu";

    pub fn draw(self: MainMenu) void {
        if (self.active) {
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
        if (self.active) {
            if (self.*.playBtn.update() == .released) {
                self.*.active = false;
                return .play;
            } else if (self.*.exitBtn.update() == .released) {
                return .exit;
            }
        }

        return .nothing;
    }
};

pub const PauseMenu = struct {
    active: bool,
    continueBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 100 }, .{ .w = 200, .h = 50 }, 30),
    mainMenuBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 160 }, .{ .w = 200, .h = 50 }, 30),
    exitBtn: UI.Button = UI.Button.init(.{ .x = 290, .y = 220 }, .{ .w = 200, .h = 50 }, 30),
    const text: [:0]const u8 = "Pasued";

    pub fn draw(self: PauseMenu) void {
        if (self.active) {
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
        if (self.active) {
            if (self.*.continueBtn.update() == .released) {
                self.*.active = false;
                return .play;
            } else if (self.*.mainMenuBtn.update() == .released) {
                self.*.active = false;
                return .menu;
            } else if (self.*.exitBtn.update() == .released) {
                return .exit;
            }
        }

        return .nothing;
    }
};
