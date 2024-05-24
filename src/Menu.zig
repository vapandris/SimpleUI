// One day all of this should be in Lua so I could easily modify it dynamiclly.
const UI = @import("UI.zig");
const rl = @import("raylib");

pub const MainMenu = struct {
    playButton: UI.Button,
    exitButton: UI.Button,
    active: bool,

    // everything is hard coded :))
    pub fn init(active: bool) MainMenu {
        return .{
            .active = active,
            .playButton = UI.Button.init(.{ .x = 30, .y = 230 }, .{ .w = 100, .h = 42 }, 30),
            .exitButton = UI.Button.init(.{ .x = 30, .y = 275 }, .{ .w = 100, .h = 42 }, 30),
        };
    }

    pub fn draw(self: MainMenu) void {
        if (self.active) {
            rl.drawText("MainMenu:", self.playButton.pos.x, self.playButton.pos.y - 40, 40, rl.Color.dark_gray);
            self.playButton.draw("Play");
            self.exitButton.draw("Exit");
        }
    }

    pub fn update(self: *MainMenu) enum { play, exit, nothing } {
        if (self.active) {
            if (self.*.playButton.update() == .released) {
                self.*.active = false;
                return .play;
            }

            if (self.*.exitButton.update() == .released) {
                return .exit;
            }
        }

        return .nothing;
    }
};

pub const PauseMenu = struct {};
