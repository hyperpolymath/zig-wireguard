// SPDX-License-Identifier: AGPL-3.0-or-later
//! WireGuard peer configuration

const std = @import("std");
const Key = @import("key.zig").Key;
const AllowedIp = @import("main.zig").AllowedIp;
const Error = @import("main.zig").Error;

/// WireGuard peer
pub const Peer = struct {
    public_key: Key,
    endpoint: ?std.net.Address,
    allowed_ips: []const AllowedIp,
    persistent_keepalive: u16,

    /// Peer configuration for addPeer
    pub const Config = struct {
        public_key: Key,
        endpoint: ?std.net.Address = null,
        allowed_ips: []const AllowedIp = &.{},
        persistent_keepalive: u16 = 0,
        preshared_key: ?Key = null,
    };

    /// Create a peer from configuration
    pub fn create(config: Config) Error!Peer {
        return .{
            .public_key = config.public_key,
            .endpoint = config.endpoint,
            .allowed_ips = config.allowed_ips,
            .persistent_keepalive = config.persistent_keepalive,
        };
    }
};
