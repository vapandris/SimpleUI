// Disclamer: This code is literal dumpster fire. This isn't supposed to be readable or optimized.

const rl = @import("raylib");
const std = @import("std");

const UI = @import("UI.zig");

var gameState: union(enum) {
    mainMenu,
    gamePlaying,
    gamePaused,
} = .mainMenu;

pub fn main() anyerror!void {
    // Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    var randomButton = UI.Button.init(std.heap.c_allocator, .{ .x = 600, .y = 20 }, .{ .h = 100, .w = 200 }, 30);

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
