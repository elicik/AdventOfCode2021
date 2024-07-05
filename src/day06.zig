const std = @import("std");

const test_file =
    \\3,4,3,1,2
    \\
;

pub fn day06a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const total_fish = try getNumberOfFishAfterNDays(80, file);
    return std.fmt.allocPrint(allocator, "{d}", .{total_fish});
}

pub fn day06b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const total_fish = try getNumberOfFishAfterNDays(256, file);
    return std.fmt.allocPrint(allocator, "{d}", .{total_fish});
}

fn getNumberOfFishAfterNDays(days: u64, file: []const u8) !u64 {
    var number_of_fish_by_timer: [9]u64 = [_]u64{0} ** 9;
    {
        var i: u64 = 0;
        while (i < file.len) : (i += 2) {
            const index = try std.fmt.parseInt(u4, file[i .. i + 1], 10);
            number_of_fish_by_timer[index] += 1;
        }
    }
    {
        var day: u64 = 0;
        while (day < days) : (day += 1) {
            const new_fish = number_of_fish_by_timer[0];
            for (0..8) |i| {
                number_of_fish_by_timer[i] = number_of_fish_by_timer[i + 1];
            }
            number_of_fish_by_timer[8] = new_fish;
            number_of_fish_by_timer[6] += new_fish;
        }
    }

    var total_fish: u64 = 0;
    for (number_of_fish_by_timer) |fish| {
        total_fish += fish;
    }
    return total_fish;
}

test "Day 6a" {
    const allocator = std.testing.allocator;
    const actual = try day06a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("5934", actual);
}

test "Day 6b" {
    const allocator = std.testing.allocator;
    const actual = try day06b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("26984457539", actual);
}
