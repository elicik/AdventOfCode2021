const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "1a")) {
            const file = try getLinesFromFile(allocator, "src/day01.txt");
            defer allocator.free(file);
            const result = try day01.day01a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 1a result: {s}\n", .{result});
        }
        if (std.mem.eql(u8, arg, "1b")) {
            const file = try getLinesFromFile(allocator, "src/day01.txt");
            defer allocator.free(file);
            const result = try day01.day01b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 1b result: {s}\n", .{result});
        }
        if (std.mem.eql(u8, arg, "2a")) {
            const file = try getLinesFromFile(allocator, "src/day02.txt");
            defer allocator.free(file);
            const result = try day02.day02a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 2a result: {s}\n", .{result});
        }
        if (std.mem.eql(u8, arg, "2b")) {
            const file = try getLinesFromFile(allocator, "src/day02.txt");
            defer allocator.free(file);
            const result = try day02.day02b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 2b result: {s}\n", .{result});
        }
        if (std.mem.eql(u8, arg, "3a")) {
            const file = try getLinesFromFile(allocator, "src/day03.txt");
            defer allocator.free(file);
            const result = try day03.day03a(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 3a result: {s}\n", .{result});
        }
        if (std.mem.eql(u8, arg, "3b")) {
            const file = try getLinesFromFile(allocator, "src/day03.txt");
            defer allocator.free(file);
            const result = try day03.day03b(allocator, file);
            defer allocator.free(result);
            std.debug.print("Day 3b result: {s}\n", .{result});
        }
    }
}

fn getLinesFromFile(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_name, std.math.maxInt(usize));
}
