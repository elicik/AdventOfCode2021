const std = @import("std");

const test_file =
    \\16,1,2,0,4,2,7,1,2,14
    \\
;

pub fn day07a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    // Ideal point is the median
    var num_crabs: u64 = 1;
    for (file) |char| {
        if (char == ',') {
            num_crabs += 1;
        }
    }

    var crabs = try allocator.alloc(i32, num_crabs);
    defer allocator.free(crabs);
    var crabs_iterator = std.mem.tokenizeAny(u8, file, ",\n");
    var crab_index: u64 = 0;
    while (crabs_iterator.next()) |crab| : (crab_index += 1) {
        if (crab.len == 0) {
            break;
        }
        crabs[crab_index] = try std.fmt.parseInt(i32, crab, 10);
    }
    std.mem.sortUnstable(i32, crabs, {}, std.sort.asc(i32));
    const median = crabs[crabs.len / 2];
    var cost: u64 = 0;
    for (crabs) |crab| {
        cost += @abs(crab - median);
    }
    return std.fmt.allocPrint(allocator, "{d}", .{cost});
}

pub fn day07b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var num_crabs: u64 = 1;
    for (file) |char| {
        if (char == ',') {
            num_crabs += 1;
        }
    }

    var crabs = try allocator.alloc(i32, num_crabs);
    defer allocator.free(crabs);
    var crabs_iterator = std.mem.tokenizeAny(u8, file, ",\n");
    var crab_index: u64 = 0;
    while (crabs_iterator.next()) |crab| : (crab_index += 1) {
        if (crab.len == 0) {
            break;
        }
        crabs[crab_index] = try std.fmt.parseInt(i32, crab, 10);
    }

    // Naive solution: check all rather than go towards minimum
    var min_pos: i32 = std.math.maxInt(i32);
    var max_pos: i32 = std.math.minInt(i32);
    for (crabs) |crab| {
        if (crab > max_pos) {
            max_pos = crab;
        }
        if (crab < min_pos) {
            min_pos = crab;
        }
    }

    var best_pos: u64 = undefined;
    var best_cost: u64 = std.math.maxInt(u64);
    for (@intCast(min_pos)..@intCast(max_pos + 1)) |pos| {
        var cost: u64 = 0;
        for (crabs) |crab| {
            const distance = @abs(crab - @as(i32, @intCast(pos)));
            cost += distance * (distance + 1) / 2;
        }
        if (cost < best_cost) {
            best_cost = cost;
            best_pos = pos;
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{best_cost});
}

test "Day 7a" {
    const allocator = std.testing.allocator;
    const actual = try day07a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("37", actual);
}

test "Day 7b" {
    const allocator = std.testing.allocator;
    const actual = try day07b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("168", actual);
}
