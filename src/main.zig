const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

pub fn main() !void {
    const screen_width = 800;
    const screen_height = 450;

    const virtual_screen_width = 160;
    const virtual_screen_height = 90;

    const virtual_ratio = screen_width / virtual_screen_width;

    rl.InitWindow(screen_width, screen_height, "My Window Name");
    defer rl.CloseWindow();

    var world_space_camera = rl.Camera2D{ .zoom = 1 };

    var screen_space_camera = rl.Camera2D{ .zoom = 1 };

    const target = rl.LoadRenderTexture(virtual_screen_width, virtual_screen_height);
    defer rl.UnloadRenderTexture(target);

    const rect_0 = rl.Rectangle{ .x = 70, .y = 35, .width = 20, .height = 20 };
    const rect_1 = rl.Rectangle{ .x = 90, .y = 55, .width = 30, .height = 10 };
    const rect_2 = rl.Rectangle{ .x = 80, .y = 65, .width = 15, .height = 25 };

    const source_rect = rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(target.texture.width), .height = @floatFromInt(-target.texture.height) };
    const dest_rect = rl.Rectangle{ .x = -virtual_ratio, .y = -virtual_ratio, .width = screen_width + (virtual_ratio * 2), .height = screen_height + (virtual_ratio * 2) };

    const origin = rl.Vector2{ .x = 0, .y = 0 };

    var rotation: f32 = 0;

    var camera_x: f32 = 0;
    var camera_y: f32 = 0;

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rotation += 60 * rl.GetFrameTime();

        camera_x = @floatCast((std.math.sin(rl.GetTime()) * 50.0) - 10);
        camera_y = @floatCast(std.math.cos(rl.GetTime()) * 30);

        screen_space_camera.target = rl.Vector2{ .x = camera_x, .y = camera_y };

        world_space_camera.target.x = screen_space_camera.target.x;
        screen_space_camera.target.x -= world_space_camera.target.x;
        screen_space_camera.target.x *= virtual_ratio;

        world_space_camera.target.y = screen_space_camera.target.y;
        screen_space_camera.target.y -= world_space_camera.target.y;
        screen_space_camera.target.y *= virtual_ratio;

        {
            rl.BeginTextureMode(target);
            defer rl.EndTextureMode();
            rl.ClearBackground(rl.WHITE);
            {
                rl.BeginMode2D(world_space_camera);
                defer rl.EndMode2D();
                rl.DrawRectanglePro(rect_0, origin, rotation, rl.BLACK);
                rl.DrawRectanglePro(rect_1, origin, -rotation, rl.RED);
                rl.DrawRectanglePro(rect_2, origin, rotation + 45, rl.BLUE);
            }
        }
        {
            rl.BeginDrawing();
            defer rl.EndDrawing();
            rl.ClearBackground(rl.RED);
            {
                rl.BeginMode2D(screen_space_camera);
                defer rl.EndMode2D();
                rl.DrawTexturePro(target.texture, source_rect, dest_rect, origin, 0.0, rl.WHITE);
            }
        }
    }
}
