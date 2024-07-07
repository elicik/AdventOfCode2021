const std = @import("std");

const test_file =
    \\be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    \\edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    \\fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    \\fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    \\aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    \\fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    \\dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    \\bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    \\egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    \\gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    \\
;

pub fn day08a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var count: u64 = 0;
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var halves_iterator = std.mem.splitSequence(u8, line, " | ");
        _ = halves_iterator.first();

        var digit_output_iterator = std.mem.splitScalar(u8, halves_iterator.rest(), ' ');
        while (digit_output_iterator.next()) |digit_output| {
            const contains = for ([4]u64{ 2, 3, 4, 7 }) |num| {
                if (num == digit_output.len) break true;
            } else false;
            if (contains) {
                count += 1;
            }
        }
    }
    return std.fmt.allocPrint(allocator, "{d}", .{count});
}

pub fn day08b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    // I was going to do a complicated sort of search here, but it didn't sound right
    // Given how easy part 1 was, I began thinking we can use some outputs to determine others (visual patterns)
    // I came up with this:
    // We start knowing which outputs correspond to 1, 4, 7, and 8 (by lengths 2, 4, 3, and 7)
    // We also know if any given output is in [0,6,9] (length 6) or [2,3,5] (length 5), so we can do this:
    // If a number is length 5 and contains all of the parts of 1, it is a 3
    // If a number is length 6 and contains all parts of 3, it is a 9
    // Else if a number is length 6 and contains all parts of 7, it is a 0
    // Else if a number is length 6, it is a 6
    // If a number is length 5 and a subset of 6, it is a 5
    // The last remaining number is a 2
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    const lessThan = comptime std.sort.asc(u8);
    var result: u64 = 0;
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var halves_iterator = std.mem.splitSequence(u8, line, " | ");

        var signals: [10][]u8 = [_][]u8{""} ** 10;
        const first_half = halves_iterator.first();
        var signal_iterator = std.mem.splitScalar(u8, first_half, ' ');
        var signal_iterator_i: u4 = 0;
        while (signal_iterator.next()) |signal| : (signal_iterator_i += 1) {
            signals[signal_iterator_i] = try std.fmt.allocPrint(allocator, "{s}", .{signal});
            // defer allocator.free(signals[signal_iterator_i]);
            // signals[i] = signal;
        }

        var digits: [4][]u8 = [_][]u8{""} ** 4;
        const second_half = halves_iterator.rest();
        var digit_iterator = std.mem.splitScalar(u8, second_half, ' ');
        var digit_iterator_i: u4 = 0;
        while (digit_iterator.next()) |digit| : (digit_iterator_i += 1) {
            digits[digit_iterator_i] = try std.fmt.allocPrint(allocator, "{s}", .{digit});
            // defer allocator.free(digits[digit_iterator_i]);
            // digits[i] = digit;
        }

        // Sort for easy comparison later
        for (signals) |signal| {
            std.mem.sortUnstable(u8, signal, {}, lessThan);
        }
        for (digits) |digit| {
            std.mem.sortUnstable(u8, digit, {}, lessThan);
        }

        var signal_index_to_num: [10]?u4 = [_]?u4{null} ** 10;
        var num_to_signal_index: [10]?usize = [_]?usize{null} ** 10;

        // Logic that was explained at the top
        for (signals, 0..) |signal, i| {
            if (signal.len == 2) {
                signal_index_to_num[i] = 1;
                num_to_signal_index[1] = i;
            }
            if (signal.len == 4) {
                signal_index_to_num[i] = 4;
                num_to_signal_index[4] = i;
            }
            if (signal.len == 3) {
                signal_index_to_num[i] = 7;
                num_to_signal_index[7] = i;
            }
            if (signal.len == 7) {
                signal_index_to_num[i] = 8;
                num_to_signal_index[8] = i;
            }
        }

        for (signals, 0..) |signal, i| {
            if (signal_index_to_num[i] == null and signal.len == 5 and isSubsetOf(u8, signals[@intCast(num_to_signal_index[1].?)], signal)) {
                signal_index_to_num[i] = 3;
                num_to_signal_index[3] = i;
                break;
            }
        }
        for (signals, 0..) |signal, i| {
            if (signal_index_to_num[i] == null and signal.len == 6) {
                if (isSubsetOf(u8, signals[@intCast(num_to_signal_index[3].?)], signal)) {
                    signal_index_to_num[i] = 9;
                    num_to_signal_index[9] = i;
                } else if (isSubsetOf(u8, signals[@intCast(num_to_signal_index[7].?)], signal)) {
                    signal_index_to_num[i] = 0;
                    num_to_signal_index[0] = i;
                } else {
                    signal_index_to_num[i] = 6;
                    num_to_signal_index[6] = i;
                }
            }
        }
        for (signals, 0..) |signal, i| {
            if (signal_index_to_num[i] == null and signal.len == 5) {
                if (isSubsetOf(u8, signal, signals[@intCast(num_to_signal_index[6].?)])) {
                    signal_index_to_num[i] = 5;
                    num_to_signal_index[5] = i;
                } else {
                    signal_index_to_num[i] = 2;
                    num_to_signal_index[2] = i;
                }
            }
        }

        for (digits, 0..) |digit, digit_i| {
            const assigned_digit = try for (signals, 0..) |signal, signal_i| {
                if (std.mem.eql(u8, signal, digit)) {
                    break signal_index_to_num[signal_i];
                }
            } else error.UnableToFindAssignment;
            result += assigned_digit.? * (try std.math.powi(usize, 10, 3 - digit_i));
        }

        for (0..signals.len) |i| {
            allocator.free(signals[i]);
        }
        for (0..digits.len) |i| {
            allocator.free(digits[i]);
        }
    }
    return std.fmt.allocPrint(allocator, "{d}", .{result});
}

fn isSubsetOf(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len > b.len) {
        return false;
    }
    for (a) |a_val| {
        const b_contains_a_val = for (b) |b_val| {
            if (a_val == b_val) break true;
        } else false;
        if (!b_contains_a_val) {
            return false;
        }
    }
    return true;
}

test "Day 8a" {
    const allocator = std.testing.allocator;
    const actual = try day08a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("26", actual);
}

test "Day 8b" {
    const allocator = std.testing.allocator;
    const actual = try day08b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("61229", actual);
}
