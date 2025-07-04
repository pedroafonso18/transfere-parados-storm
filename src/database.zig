const std = @import("std");
const pg = @import("pg");

// ============== [CONNECT DB] ============== //
pub fn connect_db(db_url: []const u8, allocator: std.mem.Allocator) !*pg.Pool {
    const uri = try std.Uri.parse(db_url);
    const pool = try pg.Pool.initUri(allocator, uri, .{.size=5, .timeout = 10_000});

    errdefer pg.Pool.deinit(pool);
    return pool;
}
// ============== [END CONNECT DB] ============== //



// ============== [FETCH DB] ============== //
const StormCancelados = struct {
    motivo: []const u8,
    numero: []const u8,
    chatid: []const u8
};

const Vendidos = struct {
    chatid: i32,
    numero: []const u8
};

pub fn fetch_options(pool: *pg.Pool, allocator: std.mem.Allocator) ![][]const u8 {
    var conn = try pool.acquire();
    defer conn.release();
    var result = std.ArrayList([]const u8).init(allocator);
    defer result.deinit();

    var row = try conn.query("SELECT userid::TEXT AS userid FROM usuarios WHERE cargo = 'vendedor' AND disponivel = true", .{});
    defer row.deinit();

    var i: usize = 0;
    while (try row.next()) |res| : (i+=1){
        const id = res.get([]const u8, 0);
        try result.append(id);
    }

    return result.toOwnedSlice();
}

// ============== [END FETCH DB] ============== //