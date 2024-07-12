const std = @import("std");

const test_file =
    \\6,10
    \\0,14
    \\9,10
    \\0,3
    \\10,4
    \\4,11
    \\6,0
    \\6,12
    \\4,1
    \\0,13
    \\10,12
    \\3,4
    \\3,0
    \\8,4
    \\1,10
    \\2,14
    \\8,10
    \\9,0
    \\
    \\fold along y=7
    \\fold along x=5
    \\
;

pub fn day13a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var file_iterator = std.mem.splitSequence(u8, file, "\n\n");
    const dots_input = file_iterator.next().?;

    var num_dots: usize = 1;
    {
        for (dots_input) |char| {
            if (char == '\n') {
                num_dots += 1;
            }
        }
    }

    const Dot = struct {
        x: u16,
        y: u16,
        fn eql(self: *@This(), other: *@This()) bool {
            return (self.x == other.x and self.y == other.y);
        }
        fn printGrid(dots: []?@This(), max_x: usize, max_y: usize) void {
            for (0..max_y + 1) |y| {
                for (0..max_x + 1) |x| {
                    const dot_contains: bool = for (dots) |potentially_dot| {
                        if (potentially_dot) |dot| {
                            if (dot.x == x and dot.y == y) {
                                break true;
                            }
                        }
                    } else false;
                    std.debug.print("{s}", .{if (dot_contains) "#" else "."});
                }
                std.debug.print("\n", .{});
            }
            std.debug.print("\n", .{});
        }
    };

    var dots: []?Dot = try allocator.alloc(?Dot, num_dots);
    defer allocator.free(dots);

    var dots_iterator = std.mem.splitScalar(u8, dots_input, '\n');
    {
        var dot_i: usize = 0;
        while (dots_iterator.next()) |dot_input| : (dot_i += 1) {
            var dot_iterator = std.mem.splitScalar(u8, dot_input, ',');
            const dot = Dot{
                .x = try std.fmt.parseInt(u16, dot_iterator.next().?, 10),
                .y = try std.fmt.parseInt(u16, dot_iterator.next().?, 10),
            };
            dots[dot_i] = dot;
        }
    }

    var max_x: usize = 0;
    var max_y: usize = 0;
    for (dots) |dot| {
        if (dot.?.x > max_x) {
            max_x = dot.?.x;
        }
        if (dot.?.y > max_y) {
            max_y = dot.?.y;
        }
    }

    var folds_iterator = std.mem.tokenizeScalar(u8, file_iterator.next().?, '\n');
    while (folds_iterator.next()) |fold| {
        const fold_direction = fold[11];
        const fold_index = try std.fmt.parseInt(u16, fold[13..], 10);
        for (0..dots.len) |dot_i| {
            if (fold_direction == 'y') {
                if (dots[dot_i]) |*dot_ptr| {
                    if (dot_ptr.y == fold_index) {
                        dots[dot_i] = null;
                    }
                    if (dot_ptr.y > fold_index) {
                        const difference = dot_ptr.y - fold_index;
                        dot_ptr.y = fold_index - difference;
                    }
                }
                max_y = fold_index - 1;
            }
            if (fold_direction == 'x') {
                if (dots[dot_i]) |*dot_ptr| {
                    if (dot_ptr.x == fold_index) {
                        dots[dot_i] = null;
                    }
                    if (dot_ptr.x > fold_index) {
                        const difference = dot_ptr.x - fold_index;
                        dot_ptr.x = fold_index - difference;
                    }
                }
                max_x = fold_index - 1;
            }
        }
        break;
    }

    var count_of_visible_dots: usize = 0;
    // This is O(num_dots * num_dots), which at least is better than O(max_x * max_y * num_dots)
    for (0..num_dots) |dot_i| {
        if (dots[dot_i]) |*dot| {
            var already_counted_dot: bool = false;
            for (0..dot_i) |dot_j| {
                if (dots[dot_j]) |*other_dot| {
                    if (dot.eql(other_dot)) {
                        already_counted_dot = true;
                    }
                }
            }
            if (!already_counted_dot) {
                count_of_visible_dots += 1;
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{count_of_visible_dots});
}

pub fn day13b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var file_iterator = std.mem.splitSequence(u8, file, "\n\n");
    const dots_input = file_iterator.next().?;

    var num_dots: usize = 1;
    {
        for (dots_input) |char| {
            if (char == '\n') {
                num_dots += 1;
            }
        }
    }

    const Dot = struct {
        x: u16,
        y: u16,
        fn eql(self: *@This(), other: *@This()) bool {
            return (self.x == other.x and self.y == other.y);
        }
        fn printGrid(dots: []?@This(), max_x: usize, max_y: usize) void {
            for (0..max_y + 1) |y| {
                for (0..max_x + 1) |x| {
                    const dot_contains: bool = for (dots) |potentially_dot| {
                        if (potentially_dot) |dot| {
                            if (dot.x == x and dot.y == y) {
                                break true;
                            }
                        }
                    } else false;
                    std.debug.print("{s}", .{if (dot_contains) "#" else "."});
                }
                std.debug.print("\n", .{});
            }
            std.debug.print("\n", .{});
        }
        fn writeGrid(dots: []?@This(), max_x: usize, max_y: usize, alloc: std.mem.Allocator) ![]const u8 {
            var backing_list = std.ArrayList(u8).init(alloc);
            defer backing_list.deinit();
            const writer = backing_list.writer();
            try writer.writeByte('\n');
            for (0..max_y + 1) |y| {
                for (0..max_x + 1) |x| {
                    const dot_contains: bool = for (dots) |potentially_dot| {
                        if (potentially_dot) |dot| {
                            if (dot.x == x and dot.y == y) {
                                break true;
                            }
                        }
                    } else false;
                    try writer.writeByte(if (dot_contains) '#' else '.');
                }
                try writer.writeByte('\n');
            }
            return try backing_list.toOwnedSlice();
        }
    };

    var dots: []?Dot = try allocator.alloc(?Dot, num_dots);
    defer allocator.free(dots);

    var dots_iterator = std.mem.splitScalar(u8, dots_input, '\n');
    {
        var dot_i: usize = 0;
        while (dots_iterator.next()) |dot_input| : (dot_i += 1) {
            var dot_iterator = std.mem.splitScalar(u8, dot_input, ',');
            const dot = Dot{
                .x = try std.fmt.parseInt(u16, dot_iterator.next().?, 10),
                .y = try std.fmt.parseInt(u16, dot_iterator.next().?, 10),
            };
            dots[dot_i] = dot;
        }
    }

    var max_x: usize = 0;
    var max_y: usize = 0;
    for (dots) |dot| {
        if (dot.?.x > max_x) {
            max_x = dot.?.x;
        }
        if (dot.?.y > max_y) {
            max_y = dot.?.y;
        }
    }

    var folds_iterator = std.mem.tokenizeScalar(u8, file_iterator.next().?, '\n');
    while (folds_iterator.next()) |fold| {
        const fold_direction = fold[11];
        const fold_index = try std.fmt.parseInt(u16, fold[13..], 10);
        for (0..dots.len) |dot_i| {
            if (fold_direction == 'y') {
                if (dots[dot_i]) |*dot_ptr| {
                    if (dot_ptr.y == fold_index) {
                        dots[dot_i] = null;
                    }
                    if (dot_ptr.y > fold_index) {
                        const difference = dot_ptr.y - fold_index;
                        dot_ptr.y = fold_index - difference;
                    }
                }
                max_y = fold_index - 1;
            }
            if (fold_direction == 'x') {
                if (dots[dot_i]) |*dot_ptr| {
                    if (dot_ptr.x == fold_index) {
                        dots[dot_i] = null;
                    }
                    if (dot_ptr.x > fold_index) {
                        const difference = dot_ptr.x - fold_index;
                        dot_ptr.x = fold_index - difference;
                    }
                }
                max_x = fold_index - 1;
            }
        }
    }

    const allocated_string = try Dot.writeGrid(dots, max_x, max_y, allocator);

    return allocated_string;
}

test "Day 13a" {
    const allocator = std.testing.allocator;
    const actual = try day13a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("17", actual);
}

// No test exists for day 13b
