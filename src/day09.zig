const std = @import("std");

const test_file =
    \\2199943210
    \\3987894921
    \\9856789892
    \\8767896789
    \\9899965678
    \\
;

pub fn day09a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    const width: usize = line_iterator.first().len;
    const height: usize = file.len / (width + 1);
    const grid: [][]u4 = try allocator.alloc([]u4, height);
    defer allocator.free(grid);
    for (0..height) |i| {
        grid[i] = try allocator.alloc(u4, width);
    }
    defer {
        for (0..height) |i| {
            allocator.free(grid[i]);
        }
    }

    line_iterator.reset();
    var line_i: usize = 0;
    while (line_iterator.next()) |line| : (line_i += 1) {
        if (line.len == 0) {
            break;
        }
        for (0..width) |char_i| {
            grid[line_i][char_i] = try std.fmt.parseInt(u4, line[char_i .. char_i + 1], 10);
        }
    }

    var total: usize = 0;

    for (0..height) |row_num| {
        for (0..width) |col_num| {
            const curr: u4 = grid[row_num][col_num];
            if (row_num != 0 and curr >= grid[row_num - 1][col_num]) {
                continue;
            }
            if (row_num != height - 1 and curr >= grid[row_num + 1][col_num]) {
                continue;
            }
            if (col_num != 0 and curr >= grid[row_num][col_num - 1]) {
                continue;
            }
            if (col_num != width - 1 and curr >= grid[row_num][col_num + 1]) {
                continue;
            }
            total += curr + 1;
        }
    }
    return std.fmt.allocPrint(allocator, "{d}", .{total});
}

pub fn day09b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..1]});
}

test "Day 9a" {
    const allocator = std.testing.allocator;
    const actual = try day09a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("15", actual);
}

test "Day 9b" {
    const allocator = std.testing.allocator;
    const actual = try day09b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("2", actual);
}
