const std = @import("std");

const test_file =
    \\0,9 -> 5,9
    \\8,0 -> 0,8
    \\9,4 -> 3,4
    \\2,2 -> 2,1
    \\7,0 -> 7,4
    \\6,4 -> 2,0
    \\0,9 -> 2,9
    \\3,4 -> 1,4
    \\0,0 -> 8,8
    \\5,5 -> 8,2
    \\
;

pub fn day05a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var grid = try allocator.alloc([1024]u2, 1024);
    defer allocator.free(grid);
    for (0..1024) |i| {
        for (0..1024) |j| {
            grid[i][j] = 0;
        }
    }

    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var token_iterator = std.mem.tokenizeAny(u8, line, " ->,");
        const x1 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const y1 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const x2 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const y2 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        if (!(x1 == x2 or y1 == y2)) {
            continue;
        }
        if (x1 == x2) {
            const min_y = @min(y1, y2);
            const max_y = @max(y1, y2);
            for (min_y..max_y + 1) |y| {
                grid[x1][y] +|= 1;
            }
        } else if (y1 == y2) {
            const min_x = @min(x1, x2);
            const max_x = @max(x1, x2);
            for (min_x..max_x + 1) |x| {
                grid[x][y1] +|= 1;
            }
        }
    }
    var total: u64 = 0;
    for (0..1024) |i| {
        for (0..1024) |j| {
            if (grid[i][j] >= 2) {
                total += 1;
            }
        }
    }
    return std.fmt.allocPrint(allocator, "{d}", .{total});
}

pub fn day05b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var grid = try allocator.alloc([1024]u2, 1024);
    defer allocator.free(grid);
    for (0..1024) |i| {
        for (0..1024) |j| {
            grid[i][j] = 0;
        }
    }

    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var token_iterator = std.mem.tokenizeAny(u8, line, " ->,");
        const x1 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const y1 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const x2 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);
        const y2 = try std.fmt.parseInt(u10, token_iterator.next().?, 10);

        if (x1 == x2) {
            const min_y = @min(y1, y2);
            const max_y = @max(y1, y2);
            for (min_y..max_y + 1) |y| {
                grid[x1][y] +|= 1;
            }
        } else if (y1 == y2) {
            const min_x = @min(x1, x2);
            const max_x = @max(x1, x2);
            for (min_x..max_x + 1) |x| {
                grid[x][y1] +|= 1;
            }
        } else {
            const x_increasing: i2 = if (x2 > x1) 1 else -1;
            const y_increasing: i2 = if (y2 > y1) 1 else -1;
            const line_length = @max(x1, x2) - @min(x1, x2) + 1;
            for (0..line_length) |i| {
                const casted: i16 = @intCast(i);
                const x: usize = @intCast(x1 + x_increasing * casted);
                const y: usize = @intCast(y1 + y_increasing * casted);
                grid[x][y] +|= 1;
            }
        }
    }
    var total: u64 = 0;
    for (0..1024) |i| {
        for (0..1024) |j| {
            if (grid[i][j] >= 2) {
                total += 1;
            }
        }
    }
    return std.fmt.allocPrint(allocator, "{d}", .{total});
}

test "Day 5a" {
    const allocator = std.testing.allocator;
    const actual = try day05a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("5", actual);
}

test "Day 5b" {
    const allocator = std.testing.allocator;
    const actual = try day05b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("12", actual);
}
