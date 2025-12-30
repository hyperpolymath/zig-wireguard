// SPDX-License-Identifier: AGPL-3.0-or-later
//! Basic WireGuard tunnel example

const std = @import("std");
const wg = @import("wireguard");

pub fn main() !void {
    // Create device
    var device = try wg.Device.create("wg0");
    defer device.destroy();

    // Generate keypair
    const private_key = wg.Key.generate();
    try device.setPrivateKey(private_key);

    // Add peer (example - replace with real peer info)
    const peer_pubkey = try wg.Key.fromBase64("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
    _ = try device.addPeer(.{
        .public_key = peer_pubkey,
        .endpoint = try std.net.Address.parseIp4("1.2.3.4", 51820),
        .allowed_ips = &.{
            .{ .addr = .{ 10, 0, 0, 0 }, .cidr = 24 },
        },
        .persistent_keepalive = 25,
    });

    // Bring up tunnel
    try device.up();
    defer device.down();

    std.debug.print("WireGuard tunnel established. Press Ctrl+C to exit.\n", .{});

    // Keep running
    while (true) {
        std.time.sleep(std.time.ns_per_s);
    }
}
