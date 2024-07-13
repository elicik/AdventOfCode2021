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
    const Path = struct {
        locations: std.ArrayList(Position),
        risk: usize,
        fn init(alloc: std.mem.Allocator) @This() {
            return @This(){
                .locations = std.ArrayList(Position).init(alloc),
                .risk = 0,
            };
        }
        fn deinit(self: *@This()) void {
            self.locations.deinit();
        }
        fn clone(self: *@This()) !@This() {
            return @This(){
                .locations = try self.locations.clone(),
                .risk = self.risk,
            };
        }
        fn addLocation(self: *@This(), pos: Position, risk: usize) !void {
            try self.locations.append(pos);
            self.risk += risk;
        }
        fn isLocationInPath(self: *@This(), pos: Position) bool {
            return for (self.locations.items) |previous_location| {
                if (pos.eql(previous_location)) {
                    break true;
                }
            } else false;
        }
    };

    // A lil quadratic formula never hurt nobody
    const grid_size: usize = (std.math.sqrt(1 + 4 * file.len) - 1) / 2;

    const risk_grid: [][]u4 = try allocator.alloc([]u4, grid_size);
    for (0..grid_size) |row_i| {
        risk_grid[row_i] = try allocator.alloc(u4, grid_size);
    }
    defer {
        for (0..grid_size) |row_i| {
            allocator.free(risk_grid[row_i]);
        }
        allocator.free(risk_grid);
    }

    const minimum_distance_grid: [][]usize = try allocator.alloc([]usize, grid_size);
    for (0..grid_size) |row_i| {
        minimum_distance_grid[row_i] = try allocator.alloc(usize, grid_size);
        for (0..grid_size) |col_i| {
            minimum_distance_grid[row_i][col_i] = std.math.maxInt(usize);
        }
    }
    defer {
        for (0..grid_size) |row_i| {
            allocator.free(minimum_distance_grid[row_i]);
        }
        allocator.free(minimum_distance_grid);
    }

    var grid_i: usize = 0;
    for (file) |char| {
        if (char == '\n') {
            continue;
        }
        const row = grid_i / grid_size;
        const col = grid_i % grid_size;
        risk_grid[row][col] = try std.fmt.parseInt(u4, ([_]u8{char})[0..1], 10);
        grid_i += 1;
    }

    // BFS
    var stack: std.fifo.LinearFifo(Path, .Dynamic) = std.fifo.LinearFifo(Path, .Dynamic).init(allocator);
    defer stack.deinit();

    minimum_distance_grid[0][0] = 0;
    var initial_path = Path.init(allocator);
    try initial_path.addLocation(.{ .row = 0, .col = 0 }, 0);
    initial_path.risk = 0;
    try stack.writeItem(initial_path);

    while (stack.readItem()) |path| {
        const path_ptr = @constCast(&path);
        defer path_ptr.deinit();
        const pos = path.locations.getLast();
        // if (pos.col == grid_size - 1 and pos.row == grid_size - 1) {
        // std.debug.print("({any}): risk is {d}, stack size is {d}\n", .{ pos, path.risk, stack.count });
        //     if (path.risk < minimum_risk) {
        //         std.debug.print("Set new minimum risk\n", .{});
        //         minimum_risk = path.risk;
        //     }
        //     continue;
        // }

        if (pos.row != 0) {
            const new_pos = Position{
                .row = pos.row - 1,
                .col = pos.col,
            };
            if (!path_ptr.isLocationInPath(new_pos)) {
                var new_path = try path_ptr.clone();
                try new_path.addLocation(new_pos, risk_grid[new_pos.row][new_pos.col]);
                if (new_path.risk < minimum_distance_grid[new_pos.row][new_pos.col]) {
                    minimum_distance_grid[new_pos.row][new_pos.col] = new_path.risk;
                    try stack.writeItem(new_path);
                } else {
                    new_path.deinit();
                }
            }
        }
        if (pos.row != grid_size - 1) {
            const new_pos = Position{
                .row = pos.row + 1,
                .col = pos.col,
            };
            if (!path_ptr.isLocationInPath(new_pos)) {
                var new_path = try path_ptr.clone();
                try new_path.addLocation(new_pos, risk_grid[new_pos.row][new_pos.col]);
                if (new_path.risk < minimum_distance_grid[new_pos.row][new_pos.col]) {
                    minimum_distance_grid[new_pos.row][new_pos.col] = new_path.risk;
                    try stack.writeItem(new_path);
                } else {
                    new_path.deinit();
                }
            }
        }
        if (pos.col != 0) {
            const new_pos = Position{
                .row = pos.row,
                .col = pos.col - 1,
            };
            if (!path_ptr.isLocationInPath(new_pos)) {
                var new_path = try path_ptr.clone();
                try new_path.addLocation(new_pos, risk_grid[new_pos.row][new_pos.col]);
                if (new_path.risk < minimum_distance_grid[new_pos.row][new_pos.col]) {
                    minimum_distance_grid[new_pos.row][new_pos.col] = new_path.risk;
                    try stack.writeItem(new_path);
                } else {
                    new_path.deinit();
                }
            }
        }
        if (pos.col != grid_size - 1) {
            const new_pos = Position{
                .row = pos.row,
                .col = pos.col + 1,
            };
            if (!path_ptr.isLocationInPath(new_pos)) {
                var new_path = try path_ptr.clone();
                try new_path.addLocation(new_pos, risk_grid[new_pos.row][new_pos.col]);
                if (new_path.risk < minimum_distance_grid[new_pos.row][new_pos.col]) {
                    minimum_distance_grid[new_pos.row][new_pos.col] = new_path.risk;
                    try stack.writeItem(new_path);
                } else {
                    new_path.deinit();
                }
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{minimum_distance_grid[grid_size - 1][grid_size - 1]});
}

pub fn day15b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..1]});
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
    try std.testing.expectEqualStrings("1", actual);
}
