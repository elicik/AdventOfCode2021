const std = @import("std");

const test_file =
    \\target area: x=20..30, y=-10..-5
    \\
;

const Velocity = struct {
    x: isize,
    y: isize,
};

const Bounds = struct {
    x_lower: f64,
    x_upper: f64,
    y_lower: f64,
    y_upper: f64,
};

fn getBoundsFromFile(file: []const u8) !Bounds {
    var file_iterator = std.mem.tokenizeSequence(u8, file[13 .. file.len - 1], ", ");
    var x_iterator = std.mem.tokenizeSequence(u8, file_iterator.next().?[2..], "..");
    var y_iterator = std.mem.tokenizeSequence(u8, file_iterator.next().?[2..], "..");
    return Bounds{
        .x_lower = try std.fmt.parseFloat(f64, x_iterator.next().?),
        .x_upper = try std.fmt.parseFloat(f64, x_iterator.next().?),
        .y_lower = try std.fmt.parseFloat(f64, y_iterator.next().?),
        .y_upper = try std.fmt.parseFloat(f64, y_iterator.next().?),
    };
}

fn getPossibleVelocities(allocator: std.mem.Allocator, bounds: Bounds) ![]Velocity {
    // I cba doing the math for negative, but it would change things - most likely, I would just switch the x_max and x_min stuff
    std.debug.assert(bounds.x_lower > 0);
    std.debug.assert(bounds.x_upper > 0);

    var potential_velocities = std.ArrayList(Velocity).init(allocator);
    // No need to defer since we're return .toOwnedSlice()
    var stopping_point: f64 = 0;
    if (@abs(bounds.x_lower) > stopping_point) {
        stopping_point = @abs(bounds.x_lower);
    }
    if (@abs(bounds.x_upper) > stopping_point) {
        stopping_point = @abs(bounds.x_upper);
    }
    if (@abs(bounds.y_lower) > stopping_point) {
        stopping_point = @abs(bounds.y_lower);
    }
    if (@abs(bounds.y_upper) > stopping_point) {
        stopping_point = @abs(bounds.y_upper);
    }

    var n: isize = 1;
    const stopping_point_int: isize = @intFromFloat(stopping_point);
    while (n < stopping_point_int) : (n += 1) {
        const n_as_float: f64 = @floatFromInt(n);

        // (2 * y_max / n - 1 + n) / 2 >= v_y_0 >= (2 * y_min / n - 1 + n) / 2
        const lowest_v_y_0: isize = @intFromFloat(@ceil((2 * bounds.y_lower / n_as_float - 1 + n_as_float) / 2));
        const highest_v_y_0: isize = @intFromFloat(@floor((2 * bounds.y_upper / n_as_float - 1 + n_as_float) / 2));

        if (lowest_v_y_0 <= highest_v_y_0) {
            const lowest_v_x_0_above_n_oops: isize = @intFromFloat(@ceil((2 * bounds.x_lower / n_as_float - 1 + n_as_float) / 2));
            const highest_v_x_0_above_n_oops: isize = @intFromFloat(@floor((2 * bounds.x_upper / n_as_float - 1 + n_as_float) / 2));

            // v is in the range: [(-1-sqrt(1+8*x_max))/2), (-1+sqrt(1+8*x_max))/2)]
            const useful_x_max_sqrt: f64 = @sqrt(1 + 8 * bounds.x_upper);
            const lowest_v_x_0_below_n_by_x_max: isize = @intFromFloat(@ceil((-1 - useful_x_max_sqrt) / 2));
            const highest_v_x_0_below_n_by_x_max: isize = @intFromFloat(@floor((-1 + useful_x_max_sqrt) / 2));

            // v is NOT in the range: (-1-sqrt(1+8*x_min))/2), (-1+sqrt(1+8*x_min))/2))
            const useful_x_min_sqrt: f64 = @sqrt(1 + 8 * bounds.x_lower);
            const lowest_v_x_0_below_n_not_allowed_by_x_min: isize = @intFromFloat(@floor((-1 - useful_x_min_sqrt) / 2));
            const highest_v_x_0_below_n_not_allowed_by_x_min: isize = @intFromFloat(@ceil((-1 + useful_x_min_sqrt) / 2));

            var v_y_0 = lowest_v_y_0;
            while (v_y_0 <= highest_v_y_0) : (v_y_0 += 1) {
                var v_x_0 = lowest_v_x_0_above_n_oops;
                while (v_x_0 <= highest_v_x_0_above_n_oops) : (v_x_0 += 1) {
                    if (0 <= v_x_0 and v_x_0 >= n) {
                        const velocity = Velocity{
                            .x = v_x_0,
                            .y = v_y_0,
                        };
                        const velocity_already_there = for (potential_velocities.items) |other| {
                            if (std.meta.eql(velocity, other)) {
                                break true;
                            }
                        } else false;
                        if (!velocity_already_there) {
                            try potential_velocities.append(velocity);
                        }
                    }
                }

                v_x_0 = lowest_v_x_0_below_n_by_x_max;
                while (v_x_0 <= highest_v_x_0_below_n_by_x_max) : (v_x_0 += 1) {
                    if (0 <= v_x_0 and v_x_0 < n and (v_x_0 <= lowest_v_x_0_below_n_not_allowed_by_x_min or v_x_0 >= highest_v_x_0_below_n_not_allowed_by_x_min)) {
                        const velocity = Velocity{
                            .x = v_x_0,
                            .y = v_y_0,
                        };
                        const velocity_already_there = for (potential_velocities.items) |other| {
                            if (std.meta.eql(velocity, other)) {
                                break true;
                            }
                        } else false;
                        if (!velocity_already_there) {
                            try potential_velocities.append(velocity);
                        }
                    }
                }
            }
        }
    }
    return try potential_velocities.toOwnedSlice();
}

pub fn day17a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const bounds = try getBoundsFromFile(file);
    const potential_velocities = try getPossibleVelocities(allocator, bounds);
    defer allocator.free(potential_velocities);

    var max_velocity_y: isize = std.math.minInt(isize);
    for (potential_velocities) |velocity| {
        if (velocity.y > max_velocity_y) {
            max_velocity_y = velocity.y;
        }
    }
    const max_height: isize = @divExact(max_velocity_y * (max_velocity_y + 1), 2);

    return std.fmt.allocPrint(allocator, "{d}", .{max_height});
}

pub fn day17b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    const bounds = try getBoundsFromFile(file);
    const potential_velocities = try getPossibleVelocities(allocator, bounds);
    defer allocator.free(potential_velocities);

    return std.fmt.allocPrint(allocator, "{d}", .{potential_velocities.len});
}

test "Day 17a" {
    const allocator = std.testing.allocator;
    const actual = try day17a(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("45", actual);
}

test "Day 17b" {
    const allocator = std.testing.allocator;
    const actual = try day17b(allocator, test_file);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("112", actual);
}
