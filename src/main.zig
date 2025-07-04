const std = @import("std");
const config = @import ("config.zig");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    const cfg = config.load_env() catch |err| {
        std.debug.print("Error: Couldn't load .env: {}\n", .{err});
        return err;
    };
    std.debug.print("{s}", .{cfg.apikey});
}
