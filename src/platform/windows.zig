// SPDX-License-Identifier: AGPL-3.0-or-later
//! Windows-specific WireGuard implementation (Wintun driver)

const std = @import("std");

pub fn bringUp(name: []const u8) !void {
    _ = name;
    // Windows uses Wintun driver - different mechanism
    // TODO: Implement via Wintun API
}

pub fn bringDown(name: []const u8) !void {
    _ = name;
    // TODO: Implement via Wintun API
}
