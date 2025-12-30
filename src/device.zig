// SPDX-License-Identifier: AGPL-3.0-or-later
//! WireGuard device management

const std = @import("std");
const c = @import("c.zig");
const Key = @import("key.zig").Key;
const Peer = @import("peer.zig").Peer;
const Error = @import("main.zig").Error;

/// WireGuard network device
pub const Device = struct {
    name: [16]u8,
    handle: ?*c.wg_device,

    /// Create a new WireGuard device
    pub fn create(name: []const u8) Error!Device {
        if (name.len > 15) return Error.InvalidInterface;

        var device_name: [16]u8 = [_]u8{0} ** 16;
        @memcpy(device_name[0..name.len], name);

        // Platform-specific device creation
        const handle = c.wg_add_device(device_name[0..name.len :0]) orelse
            return Error.PermissionDenied;

        return .{
            .name = device_name,
            .handle = handle,
        };
    }

    /// Open an existing WireGuard device
    pub fn open(name: []const u8) Error!Device {
        if (name.len > 15) return Error.InvalidInterface;

        var device_name: [16]u8 = [_]u8{0} ** 16;
        @memcpy(device_name[0..name.len], name);

        var device: ?*c.wg_device = null;
        const ret = c.wg_get_device(&device, device_name[0..name.len :0]);

        if (ret != 0) return Error.DeviceNotFound;

        return .{
            .name = device_name,
            .handle = device,
        };
    }

    /// Set the device's private key
    pub fn setPrivateKey(self: *Device, key: Key) Error!void {
        if (self.handle) |h| {
            @memcpy(&h.private_key, &key.bytes);
            h.flags |= c.WGDEVICE_HAS_PRIVATE_KEY;

            const ret = c.wg_set_device(h);
            if (ret != 0) return Error.PermissionDenied;
        } else {
            return Error.DeviceNotFound;
        }
    }

    /// Add a peer to this device
    pub fn addPeer(self: *Device, config: Peer.Config) Error!Peer {
        _ = self;
        return Peer.create(config);
    }

    /// Bring the tunnel up
    pub fn up(self: *Device) Error!void {
        _ = self;
        // Platform-specific interface up
        @import("main.zig").platform.bringUp(self.name[0..]) catch
            return Error.PermissionDenied;
    }

    /// Bring the tunnel down
    pub fn down(self: *Device) void {
        @import("main.zig").platform.bringDown(self.name[0..]) catch {};
    }

    /// Destroy the device
    pub fn destroy(self: *Device) void {
        if (self.handle) |h| {
            c.wg_free_device(h);
            self.handle = null;
        }
        _ = c.wg_del_device(self.name[0..15 :0]);
    }
};
