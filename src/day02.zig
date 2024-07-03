const std = @import("std");

pub fn day02a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var hoizontal_position: u64 = 0;
    var depth: u64 = 0;
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split_line_iterator = std.mem.splitScalar(u8, line, ' ');
        const command = split_line_iterator.next().?;
        const num = try std.fmt.parseInt(u8, split_line_iterator.next().?, 10);
        if (std.mem.eql(u8, command, "forward")) {
            hoizontal_position += num;
        }
        if (std.mem.eql(u8, command, "down")) {
            depth += num;
        }
        if (std.mem.eql(u8, command, "up")) {
            depth -= num;
        }
    }
    const result = hoizontal_position * depth;
    return std.fmt.allocPrint(allocator, "{d}", .{result});
}

pub fn day02b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var hoizontal_position: u64 = 0;
    var depth: u64 = 0;
    var aim: u64 = 0;
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split_line_iterator = std.mem.splitScalar(u8, line, ' ');
        const command = split_line_iterator.next().?;
        const num = try std.fmt.parseInt(u8, split_line_iterator.next().?, 10);
        if (std.mem.eql(u8, command, "forward")) {
            hoizontal_position += num;
            depth += aim * num;
        }
        if (std.mem.eql(u8, command, "down")) {
            aim += num;
        }
        if (std.mem.eql(u8, command, "up")) {
            aim -= num;
        }
    }
    const result = hoizontal_position * depth;
    return std.fmt.allocPrint(allocator, "{d}", .{result});
}

test "Day 2a" {
    const file =
        \\forward 5
        \\down 5
        \\forward 8
        \\up 3
        \\down 8
        \\forward 2
        \\
    ;
    const allocator = std.testing.allocator;
    const actual = try day02a(allocator, file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("150", actual);
}

test "Day 2b" {
    const file =
        \\forward 5
        \\down 5
        \\forward 8
        \\up 3
        \\down 8
        \\forward 2
        \\
    ;
    const allocator = std.testing.allocator;
    const actual = try day02b(allocator, file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("900", actual);
}
