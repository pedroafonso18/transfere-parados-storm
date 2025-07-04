const std = @import("std");
const pg = @import("pg");

// ============== [CONNECT DB] ============== //
pub fn connect_db(db_url: []const u8, allocator: std.mem.Allocator) !*pg.Pool {
    const uri = try std.Uri.parse(db_url);
    const pool = try pg.Pool.initUri(allocator, uri, .{.size=5, .timeout = 10_000});

    errdefer pg.Pool.deinit(pool);
    return pool;
}
// ============== [CONNECT DB] ============== //



// ============== [FETCH DB - TYPES] ============== //
const StormCancelados = struct {
    motivo: []const u8,
    numero: []const u8,
    chatid: []const u8
};

const Vendidos = struct {
    chatid: i32,
    numero: []const u8
};
// ============== [FETCH DB - TYPES] ============== //


// ============== [FETCH DB] ============== //
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

pub fn fetch_vendidos(pool: *pg.Pool, allocator: std.mem.Allocator) ![]Vendidos {
    var conn = try pool.acquire();
    defer conn.release();
    var result = std.ArrayList(Vendidos).init(allocator);
    defer result.deinit();

    var row = try conn.query(
    \\SELECT chat_id as chatid, phone
    \\FROM "teste_huggy_comSaldo"
    \\WHERE creat_time BETWEEN(NOW() - INTERVAL '1 day') AND (NOW() - INTERVAL '2 hours')
    );
    defer row.deinit();

    var i: usize = 0;
    while (try row.next()) |res| : (i+=1) {
        const chat_id = res.get([]const u8, 0);
        const phone = res.get([]const u8, 1);
        try result.append(Vendidos  {
            .chatid = chat_id,
            .numero = phone
        });
    }
    //TODO: Change return to verify_vendidos
    return result.toOwnedSlice();
}
// ============== [FETCH DB] ============== //