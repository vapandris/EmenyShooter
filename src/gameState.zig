const std = @import("std");
const rl = @import("raylib");

const UI = @import("UI.zig");

pub var gameStatus: union(enum) {
    mainMenu,
    play,
    paused,
} = .mainMenu;

pub var game = GameState.init();
pub const GameState = struct {
    player: Circle,

    pub fn init() GameState {
        return GameState{
            .player = Circle{
                .pos = .{ .x = 400, .y = 225 },
                .r = 30,
            },
        };
    }

    pub fn draw(self: GameState) void {
        if (gameStatus == .play) {
            const p = self.player;

            rl.drawCircle(
                @intFromFloat(p.pos.x),
                @intFromFloat(p.pos.y),
                p.r,
                UI.green,
            );
        }
    }

    pub fn update(self: *GameState) void {
        if (gameStatus == .play) {
            self.*.player.pos.x += 1;
        }
    }
};

const vec2 = rl.Vector2;
const Circle = struct {
    pos: vec2,
    r: f32,

    velocity: vec2 = .{ .x = 0, .y = 0 },
    acceleration: vec2 = .{ .x = 0, .y = 0 },

    pub fn mass(self: Circle) f32 {
        return self.r * 10;
    }

    pub fn isCircleCircleOverlap(c1: Circle, c2: Circle) bool {
        const distanceSq = @abs((c1.pos.x - c2.pos.x) * (c1.pos.x - c2.pos.x) + (c1.pos.y - c2.pos.y) * (c1.pos.y - c2.pos.y));
        const radiusSq = (c1.r + c2.r) * (c1.r + c2.r);
        return distanceSq < radiusSq;
    }
};
