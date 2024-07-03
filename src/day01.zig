const std = @import("std");

pub fn day01a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var curr: u64 = try std.fmt.parseInt(u64, line_iterator.first(), 10);
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

pub fn day01b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var nums = std.ArrayList(u64).init(allocator);
    defer nums.deinit();

    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const num = try std.fmt.parseInt(u64, line, 10);
        try nums.append(num);
    }

    var sums = std.ArrayList(u64).init(allocator);
    defer sums.deinit();

    try sums.resize(nums.items.len - 2);
    for (0..(nums.items.len - 2)) |index| {
        const relevant_lines = nums.items[index .. index + 3];
        var sum: u64 = 0;
        for (relevant_lines) |line| sum += line;
        sums.items[index] = sum;
    }
    var up_counter: u64 = 0;
    var curr_sum = sums.items[0];
    for (sums.items[1..]) |sum| {
        if (sum > curr_sum) {
            up_counter += 1;
        }
        curr_sum = sum;
    }
    return std.fmt.allocPrint(allocator, "{d}", .{up_counter});
}

test "Day 1a" {
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
        \\
    ;
    const allocator = std.testing.allocator;
    const actual = try day01a(allocator, file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("7", actual);
}

test "Day 1b" {
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
        \\
    ;
    const allocator = std.testing.allocator;
    const actual = try day01b(allocator, file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("5", actual);
}
