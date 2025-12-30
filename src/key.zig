// SPDX-License-Identifier: AGPL-3.0-or-later
//! WireGuard key handling (x25519 + cicada PQ hybrid support)

const std = @import("std");
const Error = @import("main.zig").Error;

/// WireGuard key (32 bytes for x25519)
pub const Key = struct {
    bytes: [32]u8,

    /// Generate a new random private key
    pub fn generate() Key {
        var bytes: [32]u8 = undefined;
        std.crypto.random.bytes(&bytes);

        // Clamp for x25519
        bytes[0] &= 248;
        bytes[31] &= 127;
        bytes[31] |= 64;

        return .{ .bytes = bytes };
    }

    /// Derive public key from private key
    pub fn publicKey(private: Key) Key {
        const public = std.crypto.dh.X25519.recoverPublicKey(private.bytes) catch
            return .{ .bytes = [_]u8{0} ** 32 };
        return .{ .bytes = public };
    }

    /// Parse from base64
    pub fn fromBase64(encoded: []const u8) Error!Key {
        if (encoded.len != 44) return Error.InvalidKey;

        var bytes: [32]u8 = undefined;
        _ = std.base64.standard.Decoder.decode(&bytes, encoded) catch
            return Error.InvalidKey;

        return .{ .bytes = bytes };
    }

    /// Encode to base64
    pub fn toBase64(self: Key) [44]u8 {
        var encoded: [44]u8 = undefined;
        _ = std.base64.standard.Encoder.encode(&encoded, &self.bytes);
        return encoded;
    }

    /// Import from cicada post-quantum hybrid key
    /// Extracts the x25519 component from a Kyber768 + x25519 hybrid
    pub fn fromCicadaHybrid(hybrid_key: []const u8) Error!Key {
        // cicada hybrid format: [32 bytes x25519][1088 bytes Kyber768]
        if (hybrid_key.len < 32) return Error.InvalidKey;

        var key: Key = undefined;
        @memcpy(&key.bytes, hybrid_key[0..32]);
        return key;
    }
};

test "key generation" {
    const private = Key.generate();
    const public = Key.publicKey(private);

    // Keys should be different
    try std.testing.expect(!std.mem.eql(u8, &private.bytes, &public.bytes));
}

test "base64 roundtrip" {
    const original = Key.generate();
    const encoded = original.toBase64();
    const decoded = try Key.fromBase64(&encoded);

    try std.testing.expectEqualSlices(u8, &original.bytes, &decoded.bytes);
}
