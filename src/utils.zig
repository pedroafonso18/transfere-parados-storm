const std = @import("std");

fn cleanPhoneNumber(allocator: std.mem.Allocator, number: []const u8) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();
    
    for (number) |char| {
        if (char >= '0' and char <= '9') {
            try result.append(char);
        }
    }
    
    return result.toOwnedSlice();
}