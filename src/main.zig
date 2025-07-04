const std = @import("std");
const config = @import ("config.zig");
const db = @import("database.zig");
const pg = @import("pg");

pub fn main() !void {
    const cfg = config.load_env() catch |err| {
        std.debug.print("Error: Couldn't load .env: {}\n", .{err});
        return err;
    };
    std.debug.print("{s}", .{cfg.db_url_huggy});

    const allocator = std.heap.page_allocator;
    const pool= db.connect_db(cfg.db_url_huggy, allocator) catch |err| {
        std.debug.print("ERROR: AT CONNECTING TO DB: {}", .{err});
        return;
    };
    const opt = db.fetch_options(pool, allocator) catch |err| {
        std.debug.print("ERROR: AT FETCHING DATA FROM DB: {}", .{err});
        return;
    };
    for (opt) |item| {
        std.debug.print("{s}", .{item});
    }
}
