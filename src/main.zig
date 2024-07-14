const std = @import("std");

// Need to use string literals for all of these: https://github.com/ziglang/zig/issues/2206
const modules = [_]?type{
    null,
    @import("day01.zig"),
    @import("day02.zig"),
    @import("day03.zig"),
    @import("day04.zig"),
    @import("day05.zig"),
    @import("day06.zig"),
    @import("day07.zig"),
    @import("day08.zig"),
    @import("day09.zig"),
    @import("day10.zig"),
    @import("day11.zig"),
    @import("day12.zig"),
    @import("day13.zig"),
    @import("day14.zig"),
    @import("day15.zig"),
    @import("day16.zig"),
    @import("day17.zig"),
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const all = std.mem.eql(u8, args[1], "all");

    for (args[1..]) |arg| {
        inline for (1..modules.len) |day_num| {
            inline for ("ab") |part| {
                const arg_slice = std.fmt.comptimePrint("{d}{c}", .{ day_num, part });
                if (all or std.mem.eql(u8, arg, arg_slice[0..])) {
                    const day_padded_slice = std.fmt.comptimePrint("src/day{d:0>2}.txt", .{day_num});
                    const module = modules[day_num].?;
                    const function_name = std.fmt.comptimePrint("day{d:0>2}{c}", .{ day_num, part });
                    const function = @field(module, function_name);

                    const file = try getLinesFromFile(allocator, day_padded_slice);
                    defer allocator.free(file);
                    const result = try @call(.auto, function, .{ allocator, file });
                    defer allocator.free(result);
                    std.debug.print("Day {d}{c} result: {s}\n", .{ day_num, part, result });
                }
            }
        }
    }
}

fn getLinesFromFile(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_name, std.math.maxInt(usize));
}
