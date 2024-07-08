const std = @import("std");

const test_file =
    \\[({(<(())[]>[[{[]{<()<>>
    \\[(()[<>])]({[<{<<[]>>(
    \\{([(<{}[<>[]}>{[]{[(<()>
    \\(((({<>}<{<{<>}{[]{[]{}
    \\[[<[([]))<([[{}[[()]]]
    \\[{[{({}]{}}([{[{{{}}([]
    \\{<[[]]>}<{[{[{[]{()[[[]
    \\[<(<(<(<{}))><([]([]()
    \\<{([([[(<>()){}]>(<<{{
    \\<{([{{}}[<[[[<>{}]]]>[]]
    \\
;

pub fn day10a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var char_to_points = std.AutoHashMap(u8, usize).init(allocator);
    defer char_to_points.deinit();
    try char_to_points.put(')', 3);
    try char_to_points.put(']', 57);
    try char_to_points.put('}', 1197);
    try char_to_points.put('>', 25137);

    var close_to_open = std.AutoHashMap(u8, u8).init(allocator);
    defer close_to_open.deinit();
    try close_to_open.put(')', '(');
    try close_to_open.put(']', '[');
    try close_to_open.put('}', '{');
    try close_to_open.put('>', '<');

    var total: usize = 0;
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var openings = std.ArrayList(u8).init(allocator);
        defer openings.deinit();
        for (line) |curr| {
            switch (curr) {
                '(', '<', '[', '{' => {
                    try openings.append(curr);
                },
                ')', ']', '}', '>' => {
                    if (openings.items.len != 0 and (openings.getLast() == close_to_open.get(curr).?)) {
                        _ = openings.pop();
                    } else {
                        total += char_to_points.get(curr).?;
                        break;
                    }
                },
                else => unreachable,
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{total});
}

pub fn day10b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var char_to_points = std.AutoHashMap(u8, usize).init(allocator);
    defer char_to_points.deinit();
    try char_to_points.put('(', 1);
    try char_to_points.put('[', 2);
    try char_to_points.put('{', 3);
    try char_to_points.put('<', 4);

    var close_to_open = std.AutoHashMap(u8, u8).init(allocator);
    defer close_to_open.deinit();
    try close_to_open.put(')', '(');
    try close_to_open.put(']', '[');
    try close_to_open.put('}', '{');
    try close_to_open.put('>', '<');

    var score_totals = std.ArrayList(usize).init(allocator);
    defer score_totals.deinit();

    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var openings = std.ArrayList(u8).init(allocator);
        defer openings.deinit();

        var line_is_corrupt: bool = false;
        for (line) |curr| {
            switch (curr) {
                '(', '<', '[', '{' => {
                    try openings.append(curr);
                },
                ')', ']', '}', '>' => {
                    if (openings.items.len != 0 and (openings.getLast() == close_to_open.get(curr).?)) {
                        _ = openings.pop();
                    } else {
                        line_is_corrupt = true;
                        break;
                    }
                },
                else => unreachable,
            }
        }
        if (!line_is_corrupt) {
            var score_total: usize = 0;
            while (openings.popOrNull()) |opening| {
                score_total *= 5;
                score_total += char_to_points.get(opening).?;
            }
            try score_totals.append(score_total);
        }
    }

    std.mem.sortUnstable(usize, score_totals.items, {}, std.sort.asc(usize));

    const score = score_totals.items[score_totals.items.len / 2];

    return std.fmt.allocPrint(allocator, "{d}", .{score});
}

test "Day 10a" {
    const allocator = std.testing.allocator;
    const actual = try day10a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("26397", actual);
}

test "Day 10b" {
    const allocator = std.testing.allocator;
    const actual = try day10b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("288957", actual);
}
