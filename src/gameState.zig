const std = @import("std");
const rl = @import("raylib");
const timer = @import("timer.zig");

const UI = @import("UI.zig");

pub var gameStatus: union(enum) {
    mainMenu,
    play,
    paused,
} = .mainMenu;

pub var game: GameState = undefined;

pub const GameState = struct {
    const BulletArray = std.ArrayList(Circle);
    const EnemyArray = std.ArrayList(Circle);

    player: Circle,
    bullets: BulletArray,
    enemies: EnemyArray,
    enemySpawner: timer.RepeateTimer,

    pub fn init() GameState {
        return GameState{
            .player = Circle{
                .pos = .{ .x = 400, .y = 225 },
                .r = 30,
            },
            .bullets = BulletArray.init(std.heap.c_allocator),
            .enemies = EnemyArray.init(std.heap.c_allocator),
            .enemySpawner = timer.RepeateTimer.start(1400),
        };
    }

    pub fn deinit(self: GameState) void {
        self.bullets.deinit();
        self.enemies.deinit();
    }

    pub fn reset(self: *GameState) void {
        self.deinit();
        self.* = GameState.init();
    }

    pub fn draw(self: GameState) void {
        if (gameStatus != .mainMenu) {
            const text: [:0]const u8 = if (gameStatus == .play) "esc: pause" else if (gameStatus == .paused) "esc: continue" else unreachable;
            const p = self.player;

            rl.drawCircle(
                @intFromFloat(p.pos.x),
                @intFromFloat(p.pos.y),
                p.r,
                UI.green,
            );
            for (self.bullets.items) |bullet| {
                rl.drawCircle(
                    @intFromFloat(bullet.pos.x),
                    @intFromFloat(bullet.pos.y),
                    bullet.r,
                    UI.light_green,
                );
            }

            for (self.enemies.items) |enemy| {
                rl.drawCircle(
                    @intFromFloat(enemy.pos.x),
                    @intFromFloat(enemy.pos.y),
                    enemy.r,
                    rl.Color.red,
                );
            }

            // Draw UI elem (that should be a seperate entity) at the end so it is on top of everything else:
            rl.drawText(text, 10, 10, 20, UI.my_sexy_gray);
        }
    }

    pub fn update(self: *GameState) void {
        if (gameStatus == .play) {
            // Move player based on input:
            const goLeft = rl.isKeyDown(.key_a) or rl.isKeyDown(.key_left);
            const goRight = rl.isKeyDown(.key_d) or rl.isKeyDown(.key_right);
            const goUp = rl.isKeyDown(.key_w) or rl.isKeyDown(.key_up);
            const goDown = rl.isKeyDown(.key_s) or rl.isKeyDown(.key_down);

            if (goLeft) self.*.player.velocity.x -= 50;
            if (goRight) self.*.player.velocity.x += 50;
            if (goUp) self.*.player.velocity.y -= 50;
            if (goDown) self.*.player.velocity.y += 50;

            self.*.player.move(8);

            // Fire bullet if inputted:
            const fireBullet = rl.isMouseButtonPressed(.mouse_button_left);
            if (fireBullet) {
                const mousePos = rl.getMousePosition();
                const playerPos = self.player.pos;
                const velocityX = 5.0 * (mousePos.x - playerPos.x);
                const velocityY = 5.0 * (mousePos.y - playerPos.y);

                const newBullet = Circle{
                    .r = @divTrunc(self.player.r, 2),
                    .pos = .{ .x = playerPos.x, .y = playerPos.y },
                    .velocity = .{ .x = velocityX, .y = velocityY },
                };

                self.*.bullets.append(newBullet) catch |err| {
                    std.debug.print("ERROR when appending bullet to bullets: {}\n", .{err});
                };
            }

            // Move bullets:
            for (self.*.bullets.items, 0..) |*bullet, i| {
                const leftBound = -20;
                const rightBound = 820;
                const upBound = -20;
                const downBound = 470;

                bullet.move(0);

                // This solution might skip the deletion when the i-th element and the last element should be deleted in the same frame, but that's okey.
                const shouldDelete = bullet.pos.x < leftBound or bullet.pos.x > rightBound or bullet.pos.y < upBound or bullet.pos.y > downBound;
                if (shouldDelete) {
                    if (i < self.bullets.items.len) // This is needed to prevent out of bounds indexing
                        _ = self.*.bullets.swapRemove(i);
                }
            }

            // Spawn enemy:
            if (self.*.enemySpawner.loop_count() > 0) {
                const rndX: f32 = @floatFromInt(std.crypto.random.intRangeAtMost(i32, 30, 770));
                const rndY: f32 = @floatFromInt(std.crypto.random.intRangeAtMost(i32, 30, 420));

                const newEnemy = Circle{
                    .pos = .{
                        .x = rndX,
                        .y = rndY,
                    },
                    // aim for the player
                    .velocity = .{
                        .x = self.player.pos.x - rndX,
                        .y = self.player.pos.y - rndY,
                    },
                    .r = 25,
                };

                self.*.enemies.append(newEnemy) catch |err| {
                    std.debug.print("ERROR when appending enemy to enemies {}", .{err});
                };
            }

            // Move enemies:
            for (self.*.enemies.items) |*enemy| {
                enemy.*.velocity.x = self.player.pos.x - enemy.pos.x;
                enemy.*.velocity.y = self.player.pos.y - enemy.pos.y;
                enemy.move(3);
            }
        }
    }
};

const Vec2 = rl.Vector2;
const Circle = struct {
    pos: Vec2,
    r: f32,

    velocity: Vec2 = .{ .x = 0, .y = 0 },
    acceleration: Vec2 = .{ .x = 0, .y = 0 },

    pub fn mass(self: Circle) f32 {
        return self.r * 10;
    }

    pub fn isCircleCircleOverlap(c1: Circle, c2: Circle) bool {
        const distanceSq = @abs((c1.pos.x - c2.pos.x) * (c1.pos.x - c2.pos.x) + (c1.pos.y - c2.pos.y) * (c1.pos.y - c2.pos.y));
        const radiusSq = (c1.r + c2.r) * (c1.r + c2.r);
        return distanceSq < radiusSq;
    }

    pub fn move(self: *Circle, friction: f32) void {
        const frameTime = rl.getFrameTime();
        self.*.acceleration.x = -self.velocity.x * friction;
        self.*.acceleration.y = -self.velocity.y * friction;
        self.*.velocity.x += self.acceleration.x * frameTime;
        self.*.velocity.y += self.acceleration.y * frameTime;

        self.*.pos.x += self.velocity.x * frameTime;
        self.*.pos.y += self.velocity.y * frameTime;

        const speed = (self.velocity.x * self.velocity.x) + (self.velocity.y * self.velocity.y);

        // if the circle is slow enough, stop it.
        if (@abs(speed) < 250) {
            self.*.velocity = .{ .x = 0, .y = 0 };
            self.*.acceleration = .{ .x = 0, .y = 0 };
        }
    }
};
