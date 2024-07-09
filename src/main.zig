const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const day06 = @import("day06.zig");
const day07 = @import("day07.zig");
const day08 = @import("day08.zig");
const day09 = @import("day09.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const all = std.mem.eql(u8, args[1], "all");

    for (args[1..]) |arg| {
        if (all or std.mem.eql(u8, arg, "1a")) {
            const file = try getLinesFromFile(allocator, "src/day01.txt");
            defer allocator.free(file);
            const result = try day01.day01a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 1a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "1b")) {
            const file = try getLinesFromFile(allocator, "src/day01.txt");
            defer allocator.free(file);
            const result = try day01.day01b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 1b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "2a")) {
            const file = try getLinesFromFile(allocator, "src/day02.txt");
            defer allocator.free(file);
            const result = try day02.day02a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 2a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "2b")) {
            const file = try getLinesFromFile(allocator, "src/day02.txt");
            defer allocator.free(file);
            const result = try day02.day02b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 2b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "3a")) {
            const file = try getLinesFromFile(allocator, "src/day03.txt");
            defer allocator.free(file);
            const result = try day03.day03a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 3a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "3b")) {
            const file = try getLinesFromFile(allocator, "src/day03.txt");
            defer allocator.free(file);
            const result = try day03.day03b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 3b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "4a")) {
            const file = try getLinesFromFile(allocator, "src/day04.txt");
            defer allocator.free(file);
            const result = try day04.day04a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 4a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "4b")) {
            const file = try getLinesFromFile(allocator, "src/day04.txt");
            defer allocator.free(file);
            const result = try day04.day04b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 4b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "5a")) {
            const file = try getLinesFromFile(allocator, "src/day05.txt");
            defer allocator.free(file);
            const result = try day05.day05a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 5a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "5b")) {
            const file = try getLinesFromFile(allocator, "src/day05.txt");
            defer allocator.free(file);
            const result = try day05.day05b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 5b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "6a")) {
            const file = try getLinesFromFile(allocator, "src/day06.txt");
            defer allocator.free(file);
            const result = try day06.day06a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 6a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "6b")) {
            const file = try getLinesFromFile(allocator, "src/day06.txt");
            defer allocator.free(file);
            const result = try day06.day06b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 6b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "7a")) {
            const file = try getLinesFromFile(allocator, "src/day07.txt");
            defer allocator.free(file);
            const result = try day07.day07a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 7a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "7b")) {
            const file = try getLinesFromFile(allocator, "src/day07.txt");
            defer allocator.free(file);
            const result = try day07.day07b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 7b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "8a")) {
            const file = try getLinesFromFile(allocator, "src/day08.txt");
            defer allocator.free(file);
            const result = try day08.day08a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 8a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "8b")) {
            const file = try getLinesFromFile(allocator, "src/day08.txt");
            defer allocator.free(file);
            const result = try day08.day08b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 8b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "9a")) {
            const file = try getLinesFromFile(allocator, "src/day09.txt");
            defer allocator.free(file);
            const result = try day09.day09a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 9a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "9b")) {
            const file = try getLinesFromFile(allocator, "src/day09.txt");
            defer allocator.free(file);
            const result = try day09.day09b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 9b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "10a")) {
            const file = try getLinesFromFile(allocator, "src/day10.txt");
            defer allocator.free(file);
            const result = try day10.day10a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 10a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "10b")) {
            const file = try getLinesFromFile(allocator, "src/day10.txt");
            defer allocator.free(file);
            const result = try day10.day10b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 10b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "11a")) {
            const file = try getLinesFromFile(allocator, "src/day11.txt");
            defer allocator.free(file);
            const result = try day11.day11a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 11a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "11b")) {
            const file = try getLinesFromFile(allocator, "src/day11.txt");
            defer allocator.free(file);
            const result = try day11.day11b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 11b result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "12a")) {
            const file = try getLinesFromFile(allocator, "src/day12.txt");
            defer allocator.free(file);
            const result = try day12.day12a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 12a result: {s}\n", .{result});
        }
        if (all or std.mem.eql(u8, arg, "12b")) {
            const file = try getLinesFromFile(allocator, "src/day12.txt");
            defer allocator.free(file);
            const result = try day12.day12b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 12b result: {s}\n", .{result});
        }
    }
}

fn getLinesFromFile(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_name, std.math.maxInt(usize));
}
