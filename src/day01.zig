const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"world"});
}

pub fn day01a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitSequence(u8, file, "\n");
    var curr: u64 = undefined;
    if (line_iterator.next()) |line| {
        curr = try std.fmt.parseInt(u64, line, 10);
    }
    var up_counter: u64 = 0;
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const next: u64 = try std.fmt.parseInt(u64, line, 10);
        if (next > curr) {
            up_counter += 1;
        }
        curr = next;
    }
    return std.fmt.allocPrint(allocator, "{d}", .{up_counter});
}

test "Day 1a" {
    std.debug.print("Day 1a\n", .{});
    const file =
        \\199
        \\200
        \\208
        \\210
        \\200
        \\207
        \\240
        \\269
        \\260
        \\263
    ;
    const allocator = std.testing.allocator;
    const actual = try day01a(allocator, file);
    defer allocator.free(actual);
    std.debug.print("{s}\n", .{actual});
    try std.testing.expectEqualStrings("7", actual);
}
