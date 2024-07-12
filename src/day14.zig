const std = @import("std");

const test_file =
    \\NNCB
    \\
    \\CH -> B
    \\HH -> N
    \\CB -> H
    \\NH -> C
    \\HB -> C
    \\HC -> B
    \\HN -> C
    \\NN -> C
    \\BH -> H
    \\NC -> B
    \\NB -> B
    \\BN -> B
    \\BB -> N
    \\BC -> B
    \\CC -> N
    \\CN -> C
    \\
;

pub fn day14a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    // Naive approach
    var file_iterator = std.mem.tokenizeScalar(u8, file, '\n');
    const template = file_iterator.next().?;

    var rules = std.StringHashMap(u8).init(allocator);
    defer rules.deinit();
    while (file_iterator.next()) |line| {
        try rules.put(line[0..2], line[6]);
    }

    var curr = std.ArrayList(u8).init(allocator);
    defer curr.deinit();
    const writer = curr.writer();
    _ = try writer.write(template);

    for (0..10) |_| {
        var existing_polymer = try curr.toOwnedSlice();
        defer allocator.free(existing_polymer);
        for (0..(existing_polymer.len - 1)) |char_i| {
            const middle_char = rules.get(existing_polymer[char_i .. char_i + 2]).?;
            try writer.writeByte(existing_polymer[char_i]);
            try writer.writeByte(middle_char);
        }
        try writer.writeByte(existing_polymer[existing_polymer.len - 1]);
    }

    var letter_counts = std.AutoHashMap(u8, usize).init(allocator);
    defer letter_counts.deinit();
    for (curr.items) |letter| {
        const letter_result = try letter_counts.getOrPut(letter);
        if (letter_result.found_existing) {
            letter_result.value_ptr.* += 1;
        } else {
            letter_result.value_ptr.* = 1;
        }
    }
    var min_count: usize = std.math.maxInt(usize);
    var max_count: usize = std.math.minInt(usize);
    var count_iterator = letter_counts.valueIterator();
    while (count_iterator.next()) |count_ptr| {
        if (count_ptr.* > max_count) {
            max_count = count_ptr.*;
        }
        if (count_ptr.* < min_count) {
            min_count = count_ptr.*;
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{max_count - min_count});
}

pub fn day14b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..1]});
}

test "Day 14a" {
    const allocator = std.testing.allocator;
    const actual = try day14a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("1588", actual);
}

test "Day 14b" {
    const allocator = std.testing.allocator;
    const actual = try day14b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("2188189693529", actual);
}
