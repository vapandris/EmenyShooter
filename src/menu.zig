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
