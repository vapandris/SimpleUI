// Disclamer: This code is literal dumpster fire. This isn't supposed to be readable or optimized.

const rl = @import("raylib");
const std = @import("std");

const UI = @import("UI.zig");
const Menu = @import("Menu.zig");

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

    // UI-structs:
    var mainMenu = Menu.MainMenu.init(true);

    // Main game loop
    var windowShouldClose = false;
    while (!rl.windowShouldClose() and !windowShouldClose) {
        switch (gameState) {
            .mainMenu => {
                switch (mainMenu.update()) {
                    .play => {
                        gameState = .gamePlaying;
                    },
                    .exit => {
                        windowShouldClose = true;
                    },
                    .nothing => {},
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
                    mainMenu.active = true;
                    gameState = .mainMenu;
                }
                if (rl.isKeyPressed(.key_e)) {
                    windowShouldClose = true;
                }
            },
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        switch (gameState) {
            .mainMenu => {
                mainMenu.draw();
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
        //----------------------------------------------------------------------------------
    }
}
