const std = @import("std");

const Env = struct {
    apikey: []const u8,
    db_url: []const u8,
    db_local: []const u8,
    db_url_huggy: []const u8,
};

pub fn load_env() !Env {
    const allocator = std.heap.page_allocator;

    var env: Env = .{
        .apikey = "",
        .db_url = "",
        .db_local = "",
        .db_url_huggy = ""
    };

    const file = std.fs.cwd().openFile(".env", .{}) catch |err| {
        return err;
    };
    defer file.close();

    const content = file.readToEndAlloc(allocator, 1024 * 1024) catch |err| {
        return err;
    };
    defer allocator.free(content);

    var lines = std.mem.splitAny(u8, content, "\n");
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r\t");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        if (std.mem.indexOf(u8, trimmed, "=")) |eq_pos| {
            const key = std.mem.trim(u8, trimmed[0..eq_pos], " ");
            const value = std.mem.trim(u8, trimmed[eq_pos + 1 ..], " \"");

            if (std.mem.eql(u8, key, "APIKEY")) {
                env.apikey = allocator.dupe(u8, value) catch continue;
            } else if (std.mem.eql(u8, key, "DB_URL")) {
                env.db_url = allocator.dupe(u8, value) catch continue;
            } else if (std.mem.eql(u8, key, "DB_URL_HUGGY")) {
                env.db_url_huggy = allocator.dupe(u8, value) catch continue;
            } else if (std.mem.eql(u8, key, "DB_URL_LOCAL")) {
                env.db_local = allocator.dupe(u8, value) catch continue;

            }
        }
    }

    return env;
}