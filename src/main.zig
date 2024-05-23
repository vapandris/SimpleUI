// Disclamer: This code is literal dumpster fire. This isn't supposed to be readable or optimized.

const rl = @import("raylib");
const std = @import("std");

var gameState: union(enum) {
    mainMenu,
    gamePlaying,
    gamePaused,
} = .mainMenu;

const Button = struct {
    const str = std.ArrayList(u8);
    const Pos = struct { x: i32, y: i32 };
    const Size = struct { w: i32, h: i32 };

    text: str,
    pos: Pos,
    size: Size,
    fontSize: u8,

    borderThickness: u8 = 5,
    textColor: rl.Color = rl.Color.black,
    bordedColor: rl.Color = rl.Color.black,
    backgroundColor: rl.Color = rl.Color.init(230, 230, 230, 255),

    // hovering and clicking will only affect the background bcs I'm lazy:
    hoverColor: rl.Color = rl.Color.light_gray,
    clickColor: rl.Color = rl.Color.init(170, 170, 170, 255),

    isHeld: bool = false,

    pub fn init(
        allocator: std.mem.Allocator,
        pos: Pos,
        size: Size,
        fontSize: u8,
    ) Button {
        var result: Button = .{
            .text = str.init(allocator),
            .pos = pos,
            .size = size,
            .fontSize = fontSize,
        };

        return result;
    }

    pub fn deinit(self: *Button) void {
        self.*.text.deinit();
    }

    pub fn draw(self: Button, text: [:0]const u8) void {
        const backgroundColor = if (self.isHeld)
            self.clickColor
        else if (self.isHovered())
            self.hoverColor
        else
            self.backgroundColor;

        const lazyPadding = 5;
        rl.drawRectangle(self.pos.x, self.pos.y, self.size.w, self.size.h, self.bordedColor);
        rl.drawRectangle(
            self.pos.x + self.borderThickness,
            self.pos.y + self.borderThickness,
            self.size.w - (2 * self.borderThickness),
            self.size.h - (2 * self.borderThickness),
            backgroundColor,
        );
        rl.drawText(
            text,
            self.pos.x + self.borderThickness + lazyPadding,
            self.pos.y + @divTrunc(self.size.h, 2) - @divTrunc(self.fontSize, 2),
            self.fontSize,
            self.textColor,
        );
    }

    pub fn updateClickStatus(self: *Button) enum { clicked, released, nothing } {
        if (self.isClicked()) {
            self.*.isHeld = true;
            return .clicked;
        } else if (self.isReleased()) {
            self.*.isHeld = false;
            return .released;
        } else {
            return .nothing;
        }
    }

    pub fn isHovered(self: Button) bool {
        const p = rl.getMousePosition();
        const bp1 = rl.Vector2{
            .x = @floatFromInt(self.pos.x),
            .y = @floatFromInt(self.pos.y),
        };
        const bp2 = rl.Vector2{
            .x = @floatFromInt(self.pos.x + self.size.w),
            .y = @floatFromInt(self.pos.y + self.size.h),
        };
        const isMouseColliding = (bp1.x <= p.x and p.x <= bp2.x) and (bp1.y <= p.y and p.y <= bp2.y);
        return isMouseColliding;
    }

    fn isClicked(self: Button) bool {
        const isMouseClicked = rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left);
        if (isMouseClicked) {
            return self.isHovered();
        }
        return false;
    }
    fn isReleased(self: Button) bool {
        if (self.isHeld) {
            const isMouseReleased = rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left);
            return isMouseReleased;
        }
        return false;
    }
};

pub fn main() anyerror!void {
    // Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    var randomButton = Button.init(std.heap.c_allocator, .{ .x = 20, .y = 20 }, .{ .h = 100, .w = 200 }, 30);

    // Main game loop
    var windowShouldClose = false;
    while (!rl.windowShouldClose() and !windowShouldClose) {
        switch (gameState) {
            .mainMenu => {
                if (rl.isKeyPressed(.key_p)) {
                    gameState = .gamePlaying;
                }
                if (rl.isKeyPressed(.key_e)) {
                    windowShouldClose = true;
                }
            },
            .gamePlaying => {
                if (rl.isKeyPressed(.key_escape)) {
                    gameState = .gamePaused;
                }
            },
            .gamePaused => {
                if (rl.isKeyPressed(.key_escape) or rl.isKeyPressed(.key_c)) {
                    gameState = .gamePlaying;
                }
                if (rl.isKeyPressed(.key_m)) {
                    gameState = .mainMenu;
                }
                if (rl.isKeyPressed(.key_e)) {
                    windowShouldClose = true;
                }
            },
        }

        if (randomButton.updateClickStatus() == .clicked) {
            std.debug.print("clicked!\n", .{});
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        switch (gameState) {
            .mainMenu => {
                rl.drawText("MainMenu:", 30, 190, 40, rl.Color.dark_gray);
                rl.drawText("p: play", 30, 230, 30, rl.Color.dark_gray);
                rl.drawText("e: exit", 30, 260, 30, rl.Color.dark_gray);
            },
            .gamePlaying => {
                rl.drawText("esc: pause", 30, 30, 30, rl.Color.dark_gray);
                rl.drawText("Intensive gameplay!!", 30, 200, 50, rl.Color.red);
            },
            .gamePaused => {
                rl.drawText("Game is paused :(", 30, 20, 40, rl.Color.dark_gray);
                rl.drawText("c/esc: continue", 30, 60, 30, rl.Color.dark_gray);
                rl.drawText("m: main menu", 30, 90, 30, rl.Color.dark_gray);
                rl.drawText("e: exit", 30, 120, 30, rl.Color.dark_gray);
            },
        }

        randomButton.draw("Some text");
        //----------------------------------------------------------------------------------
    }
}
