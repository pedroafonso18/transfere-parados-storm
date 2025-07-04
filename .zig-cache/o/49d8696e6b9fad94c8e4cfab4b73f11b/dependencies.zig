pub const packages = struct {
    pub const @"N-V-__8AAAOLAACqscul40pNN-WUdWQuGSCOYnyXgKXRxOqz" = struct {
        pub const build_root = "C:\\Users\\Usuario\\AppData\\Local\\zig\\p\\N-V-__8AAAOLAACqscul40pNN-WUdWQuGSCOYnyXgKXRxOqz";
        pub const build_zig = @import("N-V-__8AAAOLAACqscul40pNN-WUdWQuGSCOYnyXgKXRxOqz");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"N-V-__8AAHOzAQBh8wB371GN1DXTl1mKs8Rdqj0sJea0U4P7" = struct {
        pub const build_root = "C:\\Users\\Usuario\\AppData\\Local\\zig\\p\\N-V-__8AAHOzAQBh8wB371GN1DXTl1mKs8Rdqj0sJea0U4P7";
        pub const build_zig = @import("N-V-__8AAHOzAQBh8wB371GN1DXTl1mKs8Rdqj0sJea0U4P7");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"pg-0.0.0-Wp_7gfMCBgDT6BLHD1r7hNtVeXs6yJbFBkNar4uY-ZDB" = struct {
        pub const build_root = "C:\\Users\\Usuario\\AppData\\Local\\zig\\p\\pg-0.0.0-Wp_7gfMCBgDT6BLHD1r7hNtVeXs6yJbFBkNar4uY-ZDB";
        pub const build_zig = @import("pg-0.0.0-Wp_7gfMCBgDT6BLHD1r7hNtVeXs6yJbFBkNar4uY-ZDB");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "buffer", "N-V-__8AAAOLAACqscul40pNN-WUdWQuGSCOYnyXgKXRxOqz" },
            .{ "metrics", "N-V-__8AAHOzAQBh8wB371GN1DXTl1mKs8Rdqj0sJea0U4P7" },
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "pg", "pg-0.0.0-Wp_7gfMCBgDT6BLHD1r7hNtVeXs6yJbFBkNar4uY-ZDB" },
};
