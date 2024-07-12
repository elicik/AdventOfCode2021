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
    // Naive approach doesn't work anymore!
    var file_iterator = std.mem.tokenizeScalar(u8, file, '\n');
    const template = file_iterator.next().?;

    var rules = std.StringHashMap(u8).init(allocator);
    defer rules.deinit();

    var pair_counts = std.StringHashMap(usize).init(allocator);
    defer pair_counts.deinit();

    while (file_iterator.next()) |line| {
        try rules.put(line[0..2], line[6]);
        try pair_counts.put(line[0..2], 0);
    }

    for (0..(template.len - 1)) |char_i| {
        const pair = template[char_i .. char_i + 2];
        pair_counts.getPtr(pair).?.* += 1;
    }

    for (0..40) |_| {
        var next_pair_counts = std.StringHashMap(usize).init(allocator);
        var pair_keys_iterator = pair_counts.keyIterator();
        while (pair_keys_iterator.next()) |key| {
            try next_pair_counts.put(key.*, 0);
        }
        defer {
            pair_counts.deinit();
            pair_counts = next_pair_counts.move();
        }

        var pair_counts_iterator = pair_counts.iterator();
        while (pair_counts_iterator.next()) |entry| {
            const middle_char = rules.get(entry.key_ptr.*).?;
            const first_new_pair = ([2]u8{ entry.key_ptr.*[0], middle_char })[0..2];
            const second_new_pair = ([2]u8{ middle_char, entry.key_ptr.*[1] })[0..2];
            const number_of_the_existing_pair = entry.value_ptr.*;

            next_pair_counts.getPtr(first_new_pair).?.* += number_of_the_existing_pair;
            next_pair_counts.getPtr(second_new_pair).?.* += number_of_the_existing_pair;
        }
    }

    var letter_counts = std.AutoHashMap(u8, usize).init(allocator);
    defer letter_counts.deinit();
    {
        var pair_counts_iterator = pair_counts.iterator();
        while (pair_counts_iterator.next()) |entry| {
            const letter = entry.key_ptr.*[0];
            // Use the first letter of the pair, just add the final letter at the end.
            const letter_result = try letter_counts.getOrPut(letter);
            if (letter_result.found_existing) {
                letter_result.value_ptr.* += entry.value_ptr.*;
            } else {
                letter_result.value_ptr.* = entry.value_ptr.*;
            }
        }
        letter_counts.getPtr(template[template.len - 1]).?.* += 1;
    }

    var min_count: usize = std.math.maxInt(usize);
    var max_count: usize = std.math.minInt(usize);
    {
        var count_iterator = letter_counts.valueIterator();
        while (count_iterator.next()) |count_ptr| {
            if (count_ptr.* > max_count) {
                max_count = count_ptr.*;
            }
            if (count_ptr.* < min_count) {
                min_count = count_ptr.*;
            }
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{max_count - min_count});
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
