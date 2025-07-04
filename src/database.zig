const std = @import("std");
const pg = @import("pg");
const utils = @import("utils.zig");


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

const Logs = struct {
    chatid: []const u8,
    corretor: []const u8,
    sucesso: bool
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

pub fn fetch_cancelados(pool: *pg.Pool, allocator: std.mem.Allocator) ![]StormCancelados {
    var conn = try pool.acquire();
    defer conn.release();
    var result = std.ArrayList(StormCancelados).init(allocator);
    defer result.deinit();

    var row = try conn.query(
        \\SELECT cc.observacao_corretor, cc.telefone_celular 
        \\FROM contratos_cancelados cc
        \\WHERE cc.data_cancelamento::TEXT LIKE $1 || '%' 
        \\AND cc.motivo NOT LIKE '%corretor%' 
        \\AND cc.motivo NOT LIKE '%proposta em andamento%' 
        \\AND cc.motivo NOT LIKE '%Solicitado%' 
        \\AND cc.motivo NOT LIKE '%falta de assinatura%'
        \\AND cc.sala_loja = '(PARCEIROS) MEU CONSIG - AUTOMAÇÃO'
        \\AND NOT EXISTS (
        \\   SELECT 1 
        \\   FROM contratos_cancelados cc2 
        \\   WHERE cc2.telefone_celular = cc.telefone_celular 
        \\AND cc2.id > cc.id)
    );
    defer row.deinit();
    var i: usize = 0;
    while(row.next()) |res| :(i+=1) {
        const obs = res.get([]const u8, 0);
        const telefone_celular = res.get([]const u8, 1);
        result.append(StormCancelados {
            .chatid = "0",
            .motivo = obs,
            .numero = telefone_celular
        });
    }
    return result.toOwnedSlice();
}

pub fn fetch_abertos(pool: *pg.Pool, allocator: std.mem.Allocator) ![][]const u8 {
    var conn = try pool.acquire();
    defer conn.release();
    var result = std.ArrayList([]const u8).init(allocator);
    defer result.deinit();

    var row = try conn.query("SELECT telefone_celular FROM digitados_sistema WHERE data_insercao BETWEEN (NOW() - interval '3 days') AND (NOW() - interval '2 hours') AND status_contrato = 'aberto' AND corretor = '4716 - VENDA AUTOMATIZADA (MEU CONSIG)'", .{});
    defer row.deinit();

    var i: usize = 0;
    while (try row.next()) |res| : (i+=1){
        const phone = res.get([]const u8, 0);
        try result.append(phone);
    }

    return result.toOwnedSlice();
}
// ============== [FETCH DB] ============== //



// ============== [INSERT DB] ============== //
pub fn log_requests(pool: *pg.Pool, logs: [][]const u8) !void {
    var conn = try pool.acquire();
    defer conn.release();

    _ = conn.exec("INSERT INTO logs_consultados (chatid) VALUES ($1)", .{logs}) catch |err| {
        if (conn.err) |pg_err| {
            std.debug.print("ERROR: insert into logs_consultados failed: {s}", pg_err.message);
        }
        return err;
    };
}

pub fn log_transfers(pool: *pg.Pool, logs: []Logs) !void {
    if (logs.len == 0) {
        std.debug.print("WARNING: logs is empty, returning...");
        return;
    }
    var conn = try pool.acquire();
    defer conn.release();


    for (logs) |log| {
        _ = conn.exec("INSERT INTO logs_consultados (chatid, corretor_transferido, sucesso, transfer_timestamp) VALUES ($1, $2, $3, NOW())", .{log.chatid, log.corretor, log.sucesso}) catch |err| {
            if (conn.err) |pg_err| {
                std.debug.print("ERROR: insert into logs_consultados for transfer failed: {s}",pg_err.message);
            }
            return err;
        };
    }
    return;
}
// ============== [INSERT DB] ============== //



// ============== [VERIFY DB] ============== //
fn verify_cancelados_huggy(pool: *pg.Pool, cancelados: []StormCancelados, allocator: std.mem.Allocator) !StormCancelados {
    if (cancelados.len == 0) {
        std.debug.print("WARNING: cancelados is empty, returning...", .{});
        return cancelados;
    }
    var conn = try pool.acquire();
    defer conn.release();

    var result = std.ArrayList(StormCancelados).init(allocator);  
    for (cancelados) |cancelado| {
        const cleaned_number = try utils.cleanPhoneNumber(allocator, cancelado.numero);

    }
}

// ============== [VERIFY DB] ============== //