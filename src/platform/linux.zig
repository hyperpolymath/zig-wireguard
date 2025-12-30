// SPDX-License-Identifier: AGPL-3.0-or-later
//! Linux-specific WireGuard implementation (netlink + kernel module)

const std = @import("std");

pub fn bringUp(name: []const u8) !void {
    // Use ip link set <name> up
    var child = std.process.Child.init(&.{ "ip", "link", "set", name, "up" }, std.heap.page_allocator);
    _ = try child.spawnAndWait();
}

pub fn bringDown(name: []const u8) !void {
    var child = std.process.Child.init(&.{ "ip", "link", "set", name, "down" }, std.heap.page_allocator);
    _ = try child.spawnAndWait();
}
