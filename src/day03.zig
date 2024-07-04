const std = @import("std");

pub const test_file =
    \\00100
    \\11110
    \\10110
    \\10111
    \\10101
    \\01111
    \\00111
    \\11100
    \\10000
    \\11001
    \\00010
    \\01010
    \\
;

pub fn day03a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var lines_iterator = std.mem.splitScalar(u8, file, '\n');
    const digits: u64 = lines_iterator.peek().?.len;

    var ones_counters = try allocator.alloc(u64, digits);
    defer allocator.free(ones_counters);
    for (0..digits) |i| ones_counters[i] = 0;

    var num_lines: u64 = 0;
    while (lines_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        num_lines += 1;
        for (line, 0..) |char, index| {
            if (char == '1') {
                ones_counters[index] += 1;
            }
        }
    }
    var gamma: u64 = 0;
    var epsilon: u64 = 0;
    for (ones_counters, 0..) |ones, index| {
        const zeros = num_lines - ones;
        const value = try std.math.powi(u64, 2, digits - index - 1);
        if (ones > zeros) {
            gamma += value;
        } else {
            epsilon += value;
        }
    }
    const result = gamma * epsilon;
    return std.fmt.allocPrint(allocator, "{d}", .{result});
}

pub fn day03b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..2]});
}

test "Day 3a" {
    const allocator = std.testing.allocator;
    const actual = try day03a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("198", actual);
}

test "Day 3b" {
    const allocator = std.testing.allocator;
    const actual = try day03b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("asdf", actual);
}
