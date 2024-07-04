const std = @import("std");

pub const test_file =
    \\00100
    \\11110
    \\10110
    \\10111
    \\10101
    \\01111
    \\00111
    \\11100
    \\10000
    \\11001
    \\00010
    \\01010
    \\
;

pub fn day03a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var lines_iterator = std.mem.splitScalar(u8, file, '\n');
    const digits: u64 = lines_iterator.peek().?.len;

    var ones_counters = try allocator.alloc(u64, digits);
    defer allocator.free(ones_counters);
    for (0..digits) |i| ones_counters[i] = 0;

    var num_lines: u64 = 0;
    while (lines_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        num_lines += 1;
        for (line, 0..) |char, index| {
            if (char == '1') {
                ones_counters[index] += 1;
            }
        }
    }
    var gamma: u64 = 0;
    var epsilon: u64 = 0;
    for (ones_counters, 0..) |ones, index| {
        const zeros = num_lines - ones;
        const value = try std.math.powi(u64, 2, digits - index - 1);
        if (ones > zeros) {
            gamma += value;
        } else {
            epsilon += value;
        }
    }
    const result = gamma * epsilon;
    return std.fmt.allocPrint(allocator, "{d}", .{result});
}

pub fn day03b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    // Lets try a different approach, dont split and instead use the lines directly
    var line_count: u64 = 0;
    for (file) |char| {
        if (char == '\n') {
            line_count += 1;
        }
    }
    const digits: u64 = file.len / line_count - 1;
    var eligible_oxygen_ratings = try std.ArrayList([]const u8).initCapacity(allocator, line_count);
    defer eligible_oxygen_ratings.deinit();

    // Fill with lines
    for (0..line_count) |line_num| {
        const start = line_num * (digits + 1);
        eligible_oxygen_ratings.appendAssumeCapacity(file[start..(start + digits)]);
    }

    var eligible_scrubber_ratings = try eligible_oxygen_ratings.clone();
    defer eligible_scrubber_ratings.deinit();

    var oxygen_bit_position: u64 = 0;
    while (eligible_oxygen_ratings.items.len > 1) : (oxygen_bit_position += 1) {
        var ones: u64 = 0;
        for (eligible_oxygen_ratings.items) |line| {
            if (line[oxygen_bit_position] == '1') {
                ones += 1;
            }
        }
        const zeros: u64 = eligible_oxygen_ratings.items.len - ones;
        const most_common: u8 = if (ones >= zeros) '1' else '0';
        var i: u64 = eligible_oxygen_ratings.items.len;
        while (i > 0) : (i -= 1) {
            if (eligible_oxygen_ratings.items[i - 1][oxygen_bit_position] != most_common) {
                _ = eligible_oxygen_ratings.swapRemove(i - 1);
            }
        }
    }
    var scrubber_bit_position: u64 = 0;
    while (eligible_scrubber_ratings.items.len > 1) : (scrubber_bit_position += 1) {
        var ones: u64 = 0;
        for (eligible_scrubber_ratings.items) |line| {
            if (line[scrubber_bit_position] == '1') {
                ones += 1;
            }
        }
        const zeros: u64 = eligible_scrubber_ratings.items.len - ones;
        const most_common: u8 = if (ones >= zeros) '1' else '0';
        var i: u64 = eligible_scrubber_ratings.items.len;
        while (i > 0) : (i -= 1) {
            if (eligible_scrubber_ratings.items[i - 1][scrubber_bit_position] == most_common) {
                _ = eligible_scrubber_ratings.swapRemove(i - 1);
            }
        }
    }
    const oxygen_rating: u64 = try std.fmt.parseInt(u64, eligible_oxygen_ratings.items[0], 2);
    const scrubber_rating: u64 = try std.fmt.parseInt(u64, eligible_scrubber_ratings.items[0], 2);

    return std.fmt.allocPrint(allocator, "{d}", .{oxygen_rating * scrubber_rating});
}

test "Day 3a" {
    const allocator = std.testing.allocator;
    const actual = try day03a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("198", actual);
}

test "Day 3b" {
    const allocator = std.testing.allocator;
    const actual = try day03b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("230", actual);
}
