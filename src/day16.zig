const std = @import("std");

const test_file1 =
    \\8A004A801A8002F478
    \\
;
const test_file2 =
    \\620080001611562C8802118E34
    \\
;
const test_file3 =
    \\C0015000016115A2E0802F182340
    \\
;
const test_file4 =
    \\A0016C880162017C3686B18A3D4780
    \\
;

const PacketType = enum(u3) {
    Sum,
    Product,
    Minimum,
    Maximum,
    Literal,
    GreaterThan,
    LessThan,
    EqualTo,
};

const LiteralGroup = struct {
    last_group: u1,
    group_bits: []u1,
};

const LengthType = enum(u1) {
    TotalLengthInBits = 0,
    NumberOfSubpackets = 1,
};

const LiteralValue = struct {
    groups: []LiteralGroup,
    fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        allocator.free(self.groups);
    }
};

const SubpacketNumber = union(LengthType) {
    TotalLengthInBits: u15,
    NumberOfSubpackets: u11,
};

const OperatorValue = struct {
    length_type: LengthType,
    subpacket_number: SubpacketNumber,
    subpackets: []Packet,
    fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        for (self.subpackets) |packet| {
            packet.deinit(allocator);
        }
        allocator.free(self.subpackets);
    }
};

const PacketValue = union(enum) {
    Literal: LiteralValue,
    Operator: OperatorValue,
    fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        switch (self) {
            .Literal => self.Literal.deinit(allocator),
            .Operator => self.Operator.deinit(allocator),
        }
    }
};

const Packet = struct {
    packet_version: u3,
    packet_type: PacketType,
    packet_value: PacketValue,
    remaining_bits: []u1,
    fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        self.packet_value.deinit(allocator);
    }
};

fn convertHexToBits(char: u8) ![4]u1 {
    var result = [_]u1{0} ** 4;
    const converted: u4 = @intCast(try std.fmt.charToDigit(char, 16));
    result[0] = @intCast(converted >> 3);
    result[1] = @intCast(converted << 1 >> 3);
    result[2] = @intCast(converted << 2 >> 3);
    result[3] = @intCast(converted << 3 >> 3);
    return result;
}

fn convertBitsToNumber(comptime T: type, bits: []u1) !T {
    switch (@typeInfo(T)) {
        .Int => |int| {
            const num_bits = int.bits;
            if (num_bits < bits.len) {
                return error.WrongBitLength;
            }
            var result: T = 0;
            var bit_i: usize = 0;
            while (bit_i < bits.len) : (bit_i += 1) {
                result += bits[bit_i];
                if (bit_i != bits.len - 1) {
                    result <<= 1;
                }
            }
            return result;
        },
        else => return error.CantConvertToNumber,
    }
}

fn convertBitsToPacket(allocator: std.mem.Allocator, bits: []u1) !Packet {
    const version = try convertBitsToNumber(u3, bits[0..3]);
    const packet_type_num = try convertBitsToNumber(u3, bits[3..6]);
    const packet_type: PacketType = @enumFromInt(packet_type_num);
    var packet_value: PacketValue = undefined;
    var remaining_bits: []u1 = bits[6..];
    switch (packet_type) {
        .Literal => {
            var literal_groups = std.ArrayList(LiteralGroup).init(allocator);
            // No deallocation needed because we're using toOwnedSlice()
            while (true) {
                const literal_group = LiteralGroup{
                    .last_group = remaining_bits[0],
                    .group_bits = remaining_bits[1..5],
                };
                remaining_bits = remaining_bits[5..];
                try literal_groups.append(literal_group);
                if (literal_group.last_group == 0) {
                    break;
                }
            }
            packet_value = PacketValue{ .Literal = LiteralValue{
                .groups = try literal_groups.toOwnedSlice(),
            } };
        },
        else => {
            const length_type: LengthType = @enumFromInt(remaining_bits[0]);
            remaining_bits = remaining_bits[1..];
            var subpacket_number: SubpacketNumber = undefined;
            var subpackets = std.ArrayList(Packet).init(allocator);
            // No deallocation needed because we're using toOwnedSlice()
            switch (length_type) {
                .TotalLengthInBits => {
                    subpacket_number = SubpacketNumber{
                        .TotalLengthInBits = try convertBitsToNumber(u15, remaining_bits[0..15]),
                    };
                    remaining_bits = remaining_bits[15..];
                    var bits_for_subpackets = remaining_bits[0..subpacket_number.TotalLengthInBits];
                    while (bits_for_subpackets.len != 0) {
                        const subpacket = try convertBitsToPacket(allocator, bits_for_subpackets);
                        try subpackets.append(subpacket);
                        bits_for_subpackets = subpacket.remaining_bits;
                    }
                    remaining_bits = remaining_bits[subpacket_number.TotalLengthInBits..];
                },
                .NumberOfSubpackets => {
                    subpacket_number = SubpacketNumber{
                        .NumberOfSubpackets = try convertBitsToNumber(u11, remaining_bits[0..11]),
                    };
                    remaining_bits = remaining_bits[11..];
                    for (0..subpacket_number.NumberOfSubpackets) |_| {
                        const subpacket = try convertBitsToPacket(allocator, remaining_bits);
                        try subpackets.append(subpacket);
                        remaining_bits = subpacket.remaining_bits;
                    }
                },
            }
            packet_value = PacketValue{ .Operator = OperatorValue{
                .length_type = length_type,
                .subpacket_number = subpacket_number,
                .subpackets = try subpackets.toOwnedSlice(),
            } };
        },
    }
    return Packet{
        .packet_version = version,
        .packet_type = packet_type,
        .packet_value = packet_value,
        .remaining_bits = remaining_bits,
    };
}

fn getVersionSum(packet: Packet) usize {
    var result: usize = 0;
    result += packet.packet_version;
    switch (packet.packet_value) {
        .Literal => {},
        .Operator => |operator_value| {
            for (operator_value.subpackets) |subpacket| {
                result += getVersionSum(subpacket);
            }
        },
    }
    return result;
}

fn getValue(packet: Packet) usize {
    var result: usize = 0;
    switch (packet.packet_value) {
        .Literal => |literal_value| {
            for (literal_value.groups) |group| {
                for (group.group_bits) |bit| {
                    result += bit;
                    result <<= 1;
                }
            }
            result >>= 1;
        },
        .Operator => |operator_value| {
            switch (packet.packet_type) {
                .Sum => {
                    result = 0;
                    for (operator_value.subpackets) |subpacket| {
                        result += getValue(subpacket);
                    }
                },
                .Product => {
                    result = 1;
                    for (operator_value.subpackets) |subpacket| {
                        result *= getValue(subpacket);
                    }
                },
                .Minimum => {
                    result = std.math.maxInt(usize);
                    for (operator_value.subpackets) |subpacket| {
                        const value = getValue(subpacket);
                        if (value < result) {
                            result = value;
                        }
                    }
                },
                .Maximum => {
                    result = std.math.minInt(usize);
                    for (operator_value.subpackets) |subpacket| {
                        const value = getValue(subpacket);
                        if (value > result) {
                            result = value;
                        }
                    }
                },
                .GreaterThan => {
                    std.debug.assert(operator_value.subpackets.len == 2);
                    const a = getValue(operator_value.subpackets[0]);
                    const b = getValue(operator_value.subpackets[1]);
                    result = if (a > b) 1 else 0;
                },
                .LessThan => {
                    std.debug.assert(operator_value.subpackets.len == 2);
                    const a = getValue(operator_value.subpackets[0]);
                    const b = getValue(operator_value.subpackets[1]);
                    result = if (a < b) 1 else 0;
                },
                .EqualTo => {
                    std.debug.assert(operator_value.subpackets.len == 2);
                    const a = getValue(operator_value.subpackets[0]);
                    const b = getValue(operator_value.subpackets[1]);
                    result = if (a == b) 1 else 0;
                },
                else => unreachable,
            }
        },
    }
    return result;
}

pub fn day16a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const num_bits: usize = (file.len - 1) * 4;

    const bits = try allocator.alloc(u1, num_bits);
    defer allocator.free(bits);
    var file_i: usize = 0;
    // Skip the newline at the end
    while (file_i < file.len - 1) : (file_i += 1) {
        const converted = try convertHexToBits(file[file_i]);
        for (0..4) |sub_i| {
            bits[4 * file_i + sub_i] = converted[sub_i];
        }
    }

    const packet = try convertBitsToPacket(allocator, bits);
    defer packet.deinit(allocator);
    const version_sum = getVersionSum(packet);

    return std.fmt.allocPrint(allocator, "{d}", .{version_sum});
}

pub fn day16b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const num_bits: usize = (file.len - 1) * 4;

    const bits = try allocator.alloc(u1, num_bits);
    defer allocator.free(bits);
    var file_i: usize = 0;
    // Skip the newline at the end
    while (file_i < file.len - 1) : (file_i += 1) {
        const converted = try convertHexToBits(file[file_i]);
        for (0..4) |sub_i| {
            bits[4 * file_i + sub_i] = converted[sub_i];
        }
    }

    const packet = try convertBitsToPacket(allocator, bits);
    defer packet.deinit(allocator);
    const value = getValue(packet);

    return std.fmt.allocPrint(allocator, "{d}", .{value});
}

test "Day 16a - 1" {
    const allocator = std.testing.allocator;
    const actual = try day16a(allocator, test_file1);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("16", actual);
}

test "Day 16a - 2" {
    const allocator = std.testing.allocator;
    const actual = try day16a(allocator, test_file2);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("12", actual);
}

test "Day 16a - 3" {
    const allocator = std.testing.allocator;
    const actual = try day16a(allocator, test_file3);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("23", actual);
}

test "Day 16a - 4" {
    const allocator = std.testing.allocator;
    const actual = try day16a(allocator, test_file4);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("31", actual);
}

// Part 2

test "Day 16b - 1" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "C200B40A82\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("3", actual);
}

test "Day 16b - 2" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "04005AC33890\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("54", actual);
}

test "Day 16b - 3" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "880086C3E88112\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("7", actual);
}

test "Day 16b - 4" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "CE00C43D881120\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("9", actual);
}

test "Day 16b - 5" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "D8005AC2A8F0\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("1", actual);
}

test "Day 16b - 6" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "F600BC2D8F\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("0", actual);
}

test "Day 16b - 7" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "9C005AC2F8F0\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("0", actual);
}

test "Day 16b - 8" {
    const allocator = std.testing.allocator;
    const actual = try day16b(allocator, "9C0141080250320F1802104A08\n");
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("1", actual);
}
