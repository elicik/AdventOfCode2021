const std = @import("std");

const test_file1 =
    \\start-A
    \\start-b
    \\A-c
    \\A-b
    \\b-d
    \\A-end
    \\b-end
    \\
;

const test_file2 =
    \\dc-end
    \\HN-start
    \\start-kj
    \\dc-start
    \\dc-HN
    \\LN-dc
    \\HN-end
    \\kj-sa
    \\kj-HN
    \\kj-dc
    \\
;

const test_file3 =
    \\fs-end
    \\he-DX
    \\fs-he
    \\start-DX
    \\pj-DX
    \\end-zg
    \\zg-sl
    \\zg-pj
    \\pj-he
    \\RW-he
    \\fs-DX
    \\pj-RW
    \\zg-RW
    \\start-pj
    \\he-WI
    \\zg-he
    \\pj-fs
    \\start-RW
    \\
;

const Node = struct {
    leafs: [][]const u8 = undefined,
    small: bool,
    start: bool,
    end: bool,
};

pub fn day12a(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var nodes = std.StringHashMap(Node).init(allocator);
    defer nodes.deinit();

    var nodes_leaf_map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    defer {
        var nodes_leaf_map_iterator_for_dealloc = nodes_leaf_map.valueIterator();
        while (nodes_leaf_map_iterator_for_dealloc.next()) |node_arr_list_ptr| {
            node_arr_list_ptr.deinit();
        }
        nodes_leaf_map.deinit();
    }

    // Populate nodes except for leafs
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var connection_iterator = std.mem.splitScalar(u8, line, '-');
        while (connection_iterator.next()) |name| {
            const get_or_put_result = try nodes.getOrPut(name);
            if (!get_or_put_result.found_existing) {
                get_or_put_result.value_ptr.* = Node{
                    .small = for (name) |char| {
                        if (!std.ascii.isLower(char)) {
                            break false;
                        }
                    } else true,
                    .start = std.mem.eql(u8, name, "start"),
                    .end = std.mem.eql(u8, name, "end"),
                };
                const arr_list = std.ArrayList([]const u8).init(allocator);
                try nodes_leaf_map.put(name, arr_list);
            }
        }
    }

    // Populate leafs in array lists
    line_iterator.reset();
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var connection_iterator = std.mem.splitScalar(u8, line, '-');
        const node_a_name = connection_iterator.next().?;
        const node_b_name = connection_iterator.next().?;

        const node_a_arr_list_ptr = nodes_leaf_map.getPtr(node_a_name).?;
        try node_a_arr_list_ptr.append(node_b_name);
        const node_b_arr_list_ptr = nodes_leaf_map.getPtr(node_b_name).?;
        try node_b_arr_list_ptr.append(node_a_name);
    }

    // Move from the array lists back to the node structs cause very annoying otherwise
    var node_iterator = nodes.iterator();
    while (node_iterator.next()) |entry| {
        const name = entry.key_ptr.*;
        const node = entry.value_ptr;
        const node_arr_list_ptr = nodes_leaf_map.getPtr(name).?;
        node.leafs = node_arr_list_ptr.items;
    }

    var paths_to_check: std.ArrayList(std.ArrayList([]const u8)) = std.ArrayList(std.ArrayList([]const u8)).init(allocator);
    defer paths_to_check.deinit();

    var initial_path: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);
    try initial_path.append("start");
    try paths_to_check.append(initial_path);

    // Do a little traversing action
    var total_completed_paths: usize = 0;
    while (paths_to_check.popOrNull()) |path_to_check| {
        // Once we pop this path, we need to clear its memory
        defer path_to_check.deinit();
        const node = nodes.get(path_to_check.getLast()).?;
        if (node.end) {
            total_completed_paths += 1;
            continue;
        }

        for (node.leafs) |leaf| {
            const node_leaf = nodes.get(leaf).?;
            if (node_leaf.start) {
                continue;
            }
            if (node_leaf.small) {
                const leaf_in_path: bool = for (path_to_check.items) |node_in_path| {
                    if (std.mem.eql(u8, leaf, node_in_path)) {
                        break true;
                    }
                } else false;
                if (leaf_in_path) {
                    continue;
                }
            }
            var new_path: std.ArrayList([]const u8) = try path_to_check.clone();
            try new_path.append(leaf);
            try paths_to_check.append(new_path);
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{total_completed_paths});
}

pub fn day12b(allocator: std.mem.Allocator, file: []const u8) ![]const u8 {
    var nodes = std.StringHashMap(Node).init(allocator);
    defer nodes.deinit();

    var nodes_leaf_map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    defer {
        var nodes_leaf_map_iterator_for_dealloc = nodes_leaf_map.valueIterator();
        while (nodes_leaf_map_iterator_for_dealloc.next()) |node_arr_list_ptr| {
            node_arr_list_ptr.deinit();
        }
        nodes_leaf_map.deinit();
    }

    // Populate nodes except for leafs
    var line_iterator = std.mem.splitScalar(u8, file, '\n');
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var connection_iterator = std.mem.splitScalar(u8, line, '-');
        while (connection_iterator.next()) |name| {
            const get_or_put_result = try nodes.getOrPut(name);
            if (!get_or_put_result.found_existing) {
                get_or_put_result.value_ptr.* = Node{
                    .small = for (name) |char| {
                        if (!std.ascii.isLower(char)) {
                            break false;
                        }
                    } else true,
                    .start = std.mem.eql(u8, name, "start"),
                    .end = std.mem.eql(u8, name, "end"),
                };
                const arr_list = std.ArrayList([]const u8).init(allocator);
                try nodes_leaf_map.put(name, arr_list);
            }
        }
    }

    // Populate leafs in array lists
    line_iterator.reset();
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var connection_iterator = std.mem.splitScalar(u8, line, '-');
        const node_a_name = connection_iterator.next().?;
        const node_b_name = connection_iterator.next().?;

        const node_a_arr_list_ptr = nodes_leaf_map.getPtr(node_a_name).?;
        try node_a_arr_list_ptr.append(node_b_name);
        const node_b_arr_list_ptr = nodes_leaf_map.getPtr(node_b_name).?;
        try node_b_arr_list_ptr.append(node_a_name);
    }

    // Move from the array lists back to the node structs cause very annoying otherwise
    {
        var node_iterator = nodes.iterator();
        while (node_iterator.next()) |entry| {
            const name = entry.key_ptr.*;
            const node = entry.value_ptr;
            const node_arr_list_ptr = nodes_leaf_map.getPtr(name).?;
            node.leafs = node_arr_list_ptr.items;
        }
    }
    var paths_to_check: std.ArrayList(std.ArrayList([]const u8)) = std.ArrayList(std.ArrayList([]const u8)).init(allocator);
    defer paths_to_check.deinit();

    var initial_path: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);
    try initial_path.append("start");
    try paths_to_check.append(initial_path);

    // Do a little traversing action
    var total_completed_paths: usize = 0;
    while (paths_to_check.popOrNull()) |path_to_check| {
        // Once we pop this path, we need to clear its memory
        defer path_to_check.deinit();
        const node = nodes.get(path_to_check.getLast()).?;
        if (node.end) {
            total_completed_paths += 1;
            continue;
        }

        for (node.leafs) |leaf| {
            const node_leaf = nodes.get(leaf).?;
            if (node_leaf.start) {
                continue;
            }
            if (node_leaf.small) {
                const leaf_in_path: bool = for (path_to_check.items) |node_in_path| {
                    if (std.mem.eql(u8, leaf, node_in_path)) {
                        break true;
                    }
                } else false;

                // This is the only part that changes for part 2
                var node_iterator = nodes.iterator();
                const do_we_have_room_for_two: bool = while (node_iterator.next()) |entry| {
                    if (entry.value_ptr.small) {
                        var count: usize = 0;
                        for (path_to_check.items) |node_in_path| {
                            if (std.mem.eql(u8, entry.key_ptr.*, node_in_path)) {
                                count += 1;
                            }
                        }
                        if (count > 1) {
                            break false;
                        }
                    }
                } else true;

                if (!do_we_have_room_for_two and leaf_in_path) {
                    continue;
                }
            }
            var new_path: std.ArrayList([]const u8) = try path_to_check.clone();
            try new_path.append(leaf);
            try paths_to_check.append(new_path);
        }
    }

    return std.fmt.allocPrint(allocator, "{d}", .{total_completed_paths});
}

test "Day 12a - 1" {
    const allocator = std.testing.allocator;
    const actual = try day12a(allocator, test_file1);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("10", actual);
}

test "Day 12a - 2" {
    const allocator = std.testing.allocator;
    const actual = try day12a(allocator, test_file2);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("19", actual);
}
test "Day 12a - 3" {
    const allocator = std.testing.allocator;
    const actual = try day12a(allocator, test_file3);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("226", actual);
}

test "Day 12b - 1" {
    const allocator = std.testing.allocator;
    const actual = try day12b(allocator, test_file1);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("36", actual);
}

test "Day 12b - 2" {
    const allocator = std.testing.allocator;
    const actual = try day12b(allocator, test_file2);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("103", actual);
}
test "Day 12b - 3" {
    const allocator = std.testing.allocator;
    const actual = try day12b(allocator, test_file3);
    defer allocator.free(actual);
    try std.testing.expectEqualStrings("3509", actual);
}
