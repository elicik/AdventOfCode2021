const std = @import("std");

const test_file =
    \\7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
    \\22 13 17 11  0
    \\ 8  2 23  4 24
    \\21  9 14 16  7
    \\ 6 10  3 18  5
    \\ 1 12 20 15 19
    \\
    \\ 3 15  0  2 22
    \\ 9 18 13 17  5
    \\19  8  7 25 23
    \\20 11 10 24  4
    \\14 21 16 12  6
    \\
    \\14 21 17 24  4
    \\10 16 15  9 19
    \\18  8 23 26 20
    \\22 11 13  6  5
    \\ 2  0 12  3  7
    \\
;

const Board = struct {
    values: [25]u8 = undefined,
    fn init(self: *Board, raw_board: []const u8) !void {
        var tokenizer = std.mem.tokenizeAny(u8, raw_board, " ,\n");
        var i: u8 = 0;
        while (tokenizer.next()) |token| : (i += 1) {
            self.values[i] = try std.fmt.parseInt(u8, token, 10);
        }
    }

    fn isWon(self: *const Board, moves: [100]bool) bool {
        return for (0..5) |i| {
            const col_not_won = for (0..5) |j| {
                if (!moves[self.values[i + j * 5]]) {
                    break true;
                }
            } else false;
            if (!col_not_won) {
                break true;
            }

            const row_not_won = for (0..5) |j| {
                if (!moves[self.values[i * 5 + j]]) {
                    break true;
                }
            } else false;
            if (!row_not_won) {
                break true;
            }
        } else false;
    }

    fn getScore(self: *const Board, moves: [100]bool, latest_move: u8) u64 {
        var result: u64 = 0;
        for (self.values) |value| {
            if (!moves[value]) {
                result += value;
            }
        }
        result *= latest_move;
        return result;
    }
};

pub fn day04a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    var move_draws_iterator = std.mem.splitScalar(u8, line_iterator.first(), ',');
    var boards_iterator = std.mem.splitSequence(u8, line_iterator.rest(), "\n\n");

    var num_boards: u64 = 0;
    while (boards_iterator.next()) |_| {
        num_boards += 1;
    }
    boards_iterator.reset();

    var boards: []Board = try allocator.alloc(Board, num_boards);
    defer allocator.free(boards);
    var i: u64 = 0;
    while (boards_iterator.next()) |raw_board| : (i += 1) {
        var board = Board{};
        try board.init(raw_board);
        boards[i] = board;
    }

    // var boards = std.ArrayList(Board).init(allocator);
    // defer boards.deinit();
    // while (boards_iterator.next()) |raw_board| {
    //     var board = Board{};
    //     try board.init(raw_board);
    //     try boards.append(board);
    // }

    var moves: [100]bool = [_]bool{false} ** 100;
    var score: u64 = undefined;
    while (move_draws_iterator.next()) |move_str| {
        const move = try std.fmt.parseInt(u8, move_str, 10);
        moves[move] = true;
        for (boards) |board| {
            if (board.isWon(moves)) {
                score = board.getScore(moves, move);
                return std.fmt.allocPrint(allocator, "{d}", .{score});
            }
        }
    }
    unreachable;
}

test "Day 4a" {
    const allocator = std.testing.allocator;
    const actual = try day04a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("4512", actual);
}
