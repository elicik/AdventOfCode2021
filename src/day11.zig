const std = @import("std");

const test_file =
    \\5483143223
    \\2745854711
    \\5264556173
    \\6141336146
    \\6357385478
    \\4167524645
    \\2176841721
    \\6882881134
    \\4846848554
    \\5283751526
    \\
;

pub fn day11a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const Octopus = struct {
        energy: u4 = 0,
        flashed: bool = false,
    };
    var grid: [10][10]Octopus = [_][10]Octopus{([_]Octopus{.{}} ** 10)} ** 10;
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var line_i: usize = 0;
    while (line_iterator.next()) |line| : (line_i += 1) {
        if (line.len == 0) {
            break;
        }
        for (0..line.len) |char_i| {
            grid[line_i][char_i].energy = try std.fmt.parseInt(u4, line[char_i .. char_i + 1], 10);
        }
    }

    var step: usize = 0;
    var num_flashes: usize = 0;
    while (step < 100) : (step += 1) {
        for (0..10) |row| {
            for (0..10) |col| {
                grid[row][col].energy += 1;
            }
        }
        var some_flashed: bool = true;
        while (some_flashed) {
            some_flashed = false;
            for (0..10) |row| {
                for (0..10) |col| {
                    if (!grid[row][col].flashed and grid[row][col].energy > 9) {
                        grid[row][col].flashed = true;
                        some_flashed = true;
                        num_flashes += 1;
                        for ((row -| 1)..@min(10, row + 2)) |inc_row| {
                            for ((col -| 1)..@min(10, col + 2)) |inc_col| {
                                // Prevent overflow, more than 16 is fine
                                grid[inc_row][inc_col].energy +|= 1;
                            }
                        }
                    }
                }
            }
        }
        for (0..10) |row| {
            for (0..10) |col| {
                if (grid[row][col].flashed) {
                    grid[row][col].flashed = false;
                    grid[row][col].energy = 0;
                }
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{num_flashes});
}

pub fn day11b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const Octopus = struct {
        energy: u4 = 0,
        flashed: bool = false,
    };
    var grid: [10][10]Octopus = [_][10]Octopus{([_]Octopus{.{}} ** 10)} ** 10;
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var line_i: usize = 0;
    while (line_iterator.next()) |line| : (line_i += 1) {
        if (line.len == 0) {
            break;
        }
        for (0..line.len) |char_i| {
            grid[line_i][char_i].energy = try std.fmt.parseInt(u4, line[char_i .. char_i + 1], 10);
        }
    }

    var step: usize = 0;
    while (true) : (step += 1) {
        for (0..10) |row| {
            for (0..10) |col| {
                grid[row][col].energy += 1;
            }
        }
        var num_flashes_this_turn: usize = 0;
        var some_flashed: bool = true;
        while (some_flashed) {
            some_flashed = false;
            for (0..10) |row| {
                for (0..10) |col| {
                    if (!grid[row][col].flashed and grid[row][col].energy > 9) {
                        grid[row][col].flashed = true;
                        some_flashed = true;
                        num_flashes_this_turn += 1;
                        for ((row -| 1)..@min(10, row + 2)) |inc_row| {
                            for ((col -| 1)..@min(10, col + 2)) |inc_col| {
                                // Prevent overflow, more than 16 is fine
                                grid[inc_row][inc_col].energy +|= 1;
                            }
                        }
                    }
                }
            }
        }
        for (0..10) |row| {
            for (0..10) |col| {
                if (grid[row][col].flashed) {
                    grid[row][col].flashed = false;
                    grid[row][col].energy = 0;
                }
            }
        }
        if (num_flashes_this_turn == 100) {
            break;
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{step + 1});
}

test "Day 11a" {
    const allocator = std.testing.allocator;
    const actual = try day11a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("1656", actual);
}

test "Day 11b" {
    const allocator = std.testing.allocator;
    const actual = try day11b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("195", actual);
}
