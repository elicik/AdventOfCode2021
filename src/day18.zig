const std = @import("std");

// const test_file =
//     \\[1,2]
//     \\[[1,2],3]
//     \\
// ;
const test_file =
    \\[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    \\[[[5,[2,8]],4],[5,[[9,9],0]]]
    \\[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    \\[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    \\[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    \\[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    \\[[[[5,4],[7,7]],8],[[8,3],8]]
    \\[[9,3],[[9,9],[6,[4,9]]]]
    \\[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    \\[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    \\
;

const SnailfishNumberOrInt = union(enum) {
    snailfish_number: *SnailfishNumber,
    int: usize,
    fn deinit(self: @This()) void {
        switch (self) {
            .snailfish_number => |snailfish_number| {
                snailfish_number.deinit();
            },
            .int => {},
        }
    }
    fn toStr(self: @This(), allocator: std.mem.Allocator) error{ OutOfMemory, AllocPrintError }![]const u8 {
        switch (self) {
            .snailfish_number => |snailfish_number| {
                return try snailfish_number.toStr(allocator);
            },
            .int => |int| {
                return try std.fmt.allocPrint(allocator, "{d}", .{int});
            },
        }
    }
};

const SnailfishNumber = struct {
    left: SnailfishNumberOrInt,
    right: SnailfishNumberOrInt,
    allocator: std.mem.Allocator,

    fn deinit(self: *@This()) void {
        self.left.deinit();
        self.right.deinit();
        self.allocator.destroy(self);
    }

    fn fromStr(str: []const u8, allocator: std.mem.Allocator) !SnailfishNumberOrInt {
        // std.debug.print("Parsing: {s}\n", .{str});
        if (str[0] != '[') {
            // std.debug.print("It's an int\n", .{});
            return SnailfishNumberOrInt{
                .int = try std.fmt.parseInt(usize, str, 10),
            };
        } else {
            // std.debug.print("It's a snailfish number\n", .{});
            var comma_index: usize = 1;
            var pairs_deep: usize = 0;
            while (true) : (comma_index += 1) {
                switch (str[comma_index]) {
                    '[' => {
                        pairs_deep += 1;
                    },
                    ']' => {
                        pairs_deep -= 1;
                    },
                    ',' => {
                        if (pairs_deep == 0) {
                            break;
                        }
                    },
                    else => {},
                }
            }
            const left = try fromStr(str[1..comma_index], allocator);
            const right = try fromStr(str[comma_index + 1 .. str.len - 1], allocator);
            const snailfish_number = try allocator.create(@This());
            snailfish_number.* = @This(){
                .left = left,
                .right = right,
                .allocator = allocator,
            };
            return SnailfishNumberOrInt{
                .snailfish_number = snailfish_number,
            };
        }
    }

    fn reduce(_: @This()) void {
        // var pair_to_explode = identifyPairToExplode()
        // if (pair_to_explode != null)
        //     explodePair(pair) !!!!!
        //     reduce()
        //     return
        // if pair to split:
        //     split()
        //     reduct()
        //     return
    }
    fn add(left: *@This(), right: *@This()) !*@This() {
        // Use allocator from left side
        const allocator = left.allocator;
        const new_snailfish_number = try allocator.create(@This());
        new_snailfish_number.* = @This(){
            .left = SnailfishNumberOrInt{ .snailfish_number = left },
            .right = SnailfishNumberOrInt{ .snailfish_number = right },
            .allocator = allocator,
        };
        new_snailfish_number.reduce();
        return new_snailfish_number;
    }

    fn toStr(self: @This(), allocator: std.mem.Allocator) error{ OutOfMemory, AllocPrintError }![]const u8 {
        var result = std.ArrayList(u8).init(allocator);
        // No need to deinit, we are using toOwnedSlice()
        const left_str = try self.left.toStr(allocator);
        defer allocator.free(left_str);
        const right_str = try self.right.toStr(allocator);
        defer allocator.free(right_str);

        const writer = result.writer();
        try writer.writeByte('[');
        _ = try writer.write(left_str);
        try writer.writeByte(',');
        _ = try writer.write(right_str);
        try writer.writeByte(']');

        return result.toOwnedSlice();
    }
};

pub fn day18a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var line_iterator = std.mem.tokenizeScalar(u8, file, '\n');

    var accumulating_snailfish_number_ptr = try SnailfishNumber.fromStr(line_iterator.next().?, allocator);
    defer accumulating_snailfish_number_ptr.deinit();

    var accumulating_snailfish_str = try accumulating_snailfish_number_ptr.toStr(allocator);
    defer allocator.free(accumulating_snailfish_str);
    std.debug.print("{s}\n", .{accumulating_snailfish_str});

    while (line_iterator.next()) |line| {
        const snailfish_number = try SnailfishNumber.fromStr(line, allocator);

        const snailfish_str = try snailfish_number.toStr(allocator);
        defer allocator.free(snailfish_str);
        std.debug.print("Adding: {s}\n", .{snailfish_str});

        accumulating_snailfish_number_ptr.snailfish_number = try SnailfishNumber.add(accumulating_snailfish_number_ptr.snailfish_number, snailfish_number.snailfish_number);

        // Free existing str before using new one
        allocator.free(accumulating_snailfish_str);
        accumulating_snailfish_str = try accumulating_snailfish_number_ptr.toStr(allocator);
        std.debug.print("Now: {s}\n", .{accumulating_snailfish_str});
    }
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..1]});
}

pub fn day18b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}", .{file[0..1]});
}

test "Day 18a" {
    const allocator = std.testing.allocator;
    const actual = try day18a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("4140", actual);
}

test "Day 18b" {
    const allocator = std.testing.allocator;
    const actual = try day18b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("[", actual);
}
