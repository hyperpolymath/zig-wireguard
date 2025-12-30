// SPDX-License-Identifier: AGPL-3.0-or-later
//! zig-wireguard: Idiomatic Zig bindings to libwireguard
//!
//! Provides cross-platform WireGuard VPN management for:
//! - Linux (kernel module + netlink)
//! - macOS (Network.framework)
//! - FreeBSD (if_wg kernel module)
//! - Windows (Wintun driver)

const std = @import("std");
const c = @import("c.zig");

pub const Device = @import("device.zig").Device;
pub const Peer = @import("peer.zig").Peer;
pub const Key = @import("key.zig").Key;

/// Platform-specific implementations
pub const platform = switch (@import("builtin").os.tag) {
    .linux => @import("platform/linux.zig"),
    .macos => @import("platform/macos.zig"),
    .freebsd => @import("platform/freebsd.zig"),
    .windows => @import("platform/windows.zig"),
    else => @compileError("Unsupported platform for WireGuard"),
};

/// WireGuard error codes
pub const Error = error{
    DeviceNotFound,
    PermissionDenied,
    InvalidKey,
    PeerNotFound,
    EndpointUnreachable,
    NetlinkError,
    AllocationFailed,
    InvalidInterface,
};

/// Allowed IP range for peer configuration
pub const AllowedIp = struct {
    addr: [4]u8,
    cidr: u8,

    pub fn format(self: AllowedIp, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{}.{}.{}.{}/{}", .{
            self.addr[0],
            self.addr[1],
            self.addr[2],
            self.addr[3],
            self.cidr,
        });
    }
};

test "basic functionality" {
    // Platform detection
    const os = @import("builtin").os.tag;
    try std.testing.expect(os == .linux or os == .macos or os == .freebsd or os == .windows);
}
