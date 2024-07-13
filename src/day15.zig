const std = @import("std");

const test_file =
    \\1163751742
    \\1381373672
    \\2136511328
    \\3694931569
    \\7463417111
    \\1319128137
    \\1359912421
    \\3125421639
    \\1293138521
    \\2311944581
    \\
;

pub fn day15a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const Position = struct {
        row: usize,
        col: usize,
        fn eql(self: @This(), other: @This()) bool {
            return self.row == other.row and self.col == other.col;
        }
    };

    const Node = struct {
        pos: Position,
        risk: usize,
        g_score: usize = std.math.maxInt(usize), // Cheapest known risk from start to pos
        f_score: usize = std.math.maxInt(usize), // g_score + heuristic to goal (minimum value required to hit goal)
        fn heuristic(self: @This(), grid_size: usize) usize {
            // Manhattan distance
            return (grid_size - 1 - self.pos.row) + (grid_size - 1 - self.pos.col);
        }
    };

    // A lil quadratic formula never hurt nobody
    const grid_size: usize = (std.math.sqrt(1 + 4 * file.len) - 1) / 2;

    const grid: [][]Node = try allocator.alloc([]Node, grid_size);
    for (0..grid_size) |row_i| {
        grid[row_i] = try allocator.alloc(Node, grid_size);
    }
    defer {
        for (0..grid_size) |row_i| {
            allocator.free(grid[row_i]);
        }
        allocator.free(grid);
    }

    var grid_i: usize = 0;
    for (file) |char| {
        if (char == '\n') {
            continue;
        }
        const row = grid_i / grid_size;
        const col = grid_i % grid_size;
        const risk = try std.fmt.parseInt(u4, ([_]u8{char})[0..1], 10);
        grid[row][col] = Node{
            .pos = .{
                .row = row,
                .col = col,
            },
            .risk = risk,
        };
        grid_i += 1;
    }

    var start_ptr = &(grid[0][0]);
    const goal = grid[grid_size - 1][grid_size - 1];

    const NodeContext = struct {
        grid: [][]Node,
    };
    const NodeComparer = struct {
        fn lessThan(context: NodeContext, a: Position, b: Position) std.math.Order {
            const node_a = context.grid[a.row][a.col];
            const node_b = context.grid[b.row][b.col];
            return std.math.order(node_a.f_score, node_b.f_score);
        }
    };

    // A*
    var priority_queue = std.PriorityQueue(Position, NodeContext, NodeComparer.lessThan).init(allocator, .{ .grid = grid });
    defer priority_queue.deinit();

    start_ptr.g_score = 0;
    start_ptr.f_score = start_ptr.heuristic(grid_size);

    try priority_queue.add(start_ptr.pos);

    while (priority_queue.removeOrNull()) |pos| {
        if (pos.eql(goal.pos)) {
            break;
        }
        const node = grid[pos.row][pos.col];

        const neighbors = [_]?Position{
            if (pos.row != 0) (.{
                .row = pos.row - 1,
                .col = pos.col,
            }) else null,
            if (pos.row != grid_size - 1) (.{
                .row = pos.row + 1,
                .col = pos.col,
            }) else null,
            if (pos.col != 0) (.{
                .row = pos.row,
                .col = pos.col - 1,
            }) else null,
            if (pos.col != grid_size - 1) (.{
                .row = pos.row,
                .col = pos.col + 1,
            }) else null,
        };
        for (neighbors) |new_pos_optional| {
            if (new_pos_optional) |new_pos| {
                var new_node_ptr = &(grid[new_pos.row][new_pos.col]);
                const distance_from_start_to_new_node: usize = node.g_score + new_node_ptr.risk;
                if (distance_from_start_to_new_node < new_node_ptr.g_score) {
                    new_node_ptr.g_score = distance_from_start_to_new_node;
                    new_node_ptr.f_score = distance_from_start_to_new_node + new_node_ptr.heuristic(grid_size);

                    var queue_iterator = priority_queue.iterator();
                    const neighbor_in_queue = while (queue_iterator.next()) |other_position| {
                        if (new_node_ptr.pos.eql(other_position)) {
                            break true;
                        }
                    } else false;
                    if (!neighbor_in_queue) {
                        try priority_queue.add(new_node_ptr.pos);
                    }
                }
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{grid[grid_size - 1][grid_size - 1].g_score});
}

pub fn day15b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const Position = struct {
        row: usize,
        col: usize,
        fn eql(self: @This(), other: @This()) bool {
            return self.row == other.row and self.col == other.col;
        }
    };

    const Node = struct {
        pos: Position,
        risk: usize,
        g_score: usize = std.math.maxInt(usize), // Cheapest known risk from start to pos
        f_score: usize = std.math.maxInt(usize), // g_score + heuristic to goal (minimum value required to hit goal)
        fn heuristic(self: @This(), grid_size: usize) usize {
            // Manhattan distance
            return (grid_size - 1 - self.pos.row) + (grid_size - 1 - self.pos.col);
        }
    };

    // A lil quadratic formula never hurt nobody
    const original_grid_size: usize = (std.math.sqrt(1 + 4 * file.len) - 1) / 2;
    const grid_size: usize = original_grid_size * 5;

    const grid: [][]Node = try allocator.alloc([]Node, grid_size);
    for (0..grid_size) |row_i| {
        grid[row_i] = try allocator.alloc(Node, grid_size);
    }
    defer {
        for (0..grid_size) |row_i| {
            allocator.free(grid[row_i]);
        }
        allocator.free(grid);
    }

    var grid_i: usize = 0;
    for (file) |char| {
        if (char == '\n') {
            continue;
        }
        const row = grid_i / original_grid_size;
        const col = grid_i % original_grid_size;
        const risk = try std.fmt.parseInt(u4, ([_]u8{char})[0..1], 10);
        for (0..5) |row_modifier| {
            for (0..5) |col_modifier| {
                const real_row = row + row_modifier * original_grid_size;
                const real_col = col + col_modifier * original_grid_size;
                const real_risk = (risk + (row_modifier + col_modifier) - 1) % 9 + 1;
                grid[real_row][real_col] = Node{
                    .pos = .{
                        .row = real_row,
                        .col = real_col,
                    },
                    .risk = real_risk,
                };
            }
        }
        grid_i += 1;
    }

    var start_ptr = &(grid[0][0]);
    const goal = grid[grid_size - 1][grid_size - 1];

    const NodeContext = struct {
        grid: [][]Node,
    };
    const NodeComparer = struct {
        fn lessThan(context: NodeContext, a: Position, b: Position) std.math.Order {
            const node_a = context.grid[a.row][a.col];
            const node_b = context.grid[b.row][b.col];
            return std.math.order(node_a.f_score, node_b.f_score);
        }
    };

    // A*
    var priority_queue = std.PriorityQueue(Position, NodeContext, NodeComparer.lessThan).init(allocator, .{ .grid = grid });
    defer priority_queue.deinit();

    start_ptr.g_score = 0;
    start_ptr.f_score = start_ptr.heuristic(grid_size);

    try priority_queue.add(start_ptr.pos);

    while (priority_queue.removeOrNull()) |pos| {
        if (pos.eql(goal.pos)) {
            break;
        }
        const node = grid[pos.row][pos.col];

        const neighbors = [_]?Position{
            if (pos.row != 0) (.{
                .row = pos.row - 1,
                .col = pos.col,
            }) else null,
            if (pos.row != grid_size - 1) (.{
                .row = pos.row + 1,
                .col = pos.col,
            }) else null,
            if (pos.col != 0) (.{
                .row = pos.row,
                .col = pos.col - 1,
            }) else null,
            if (pos.col != grid_size - 1) (.{
                .row = pos.row,
                .col = pos.col + 1,
            }) else null,
        };
        for (neighbors) |new_pos_optional| {
            if (new_pos_optional) |new_pos| {
                var new_node_ptr = &(grid[new_pos.row][new_pos.col]);
                const distance_from_start_to_new_node: usize = node.g_score + new_node_ptr.risk;
                if (distance_from_start_to_new_node < new_node_ptr.g_score) {
                    new_node_ptr.g_score = distance_from_start_to_new_node;
                    new_node_ptr.f_score = distance_from_start_to_new_node + new_node_ptr.heuristic(grid_size);

                    var queue_iterator = priority_queue.iterator();
                    const neighbor_in_queue = while (queue_iterator.next()) |other_position| {
                        if (new_node_ptr.pos.eql(other_position)) {
                            break true;
                        }
                    } else false;
                    if (!neighbor_in_queue) {
                        try priority_queue.add(new_node_ptr.pos);
                    }
                }
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{grid[grid_size - 1][grid_size - 1].g_score});
}

test "Day 15a" {
    const allocator = std.testing.allocator;
    const actual = try day15a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("40", actual);
}

test "Day 15b" {
    const allocator = std.testing.allocator;
    const actual = try day15b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("315", actual);
}
