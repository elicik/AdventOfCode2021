const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");

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
    }
}

fn getLinesFromFile(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_name, std.math.maxInt(usize));
}
