// SPDX-License-Identifier: AGPL-3.0-or-later
//! macOS-specific WireGuard implementation (Network.framework)

const std = @import("std");

pub fn bringUp(name: []const u8) !void {
    var child = std.process.Child.init(&.{ "ifconfig", name, "up" }, std.heap.page_allocator);
    _ = try child.spawnAndWait();
}

pub fn bringDown(name: []const u8) !void {
    var child = std.process.Child.init(&.{ "ifconfig", name, "down" }, std.heap.page_allocator);
    _ = try child.spawnAndWait();
}
