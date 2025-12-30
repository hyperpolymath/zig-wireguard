// SPDX-License-Identifier: AGPL-3.0-or-later
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library
    const lib = b.addStaticLibrary(.{
        .name = "zig-wireguard",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link libwireguard
    lib.linkSystemLibrary("wireguard");
    lib.linkLibC();

    b.installArtifact(lib);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // Example: basic tunnel
    const tunnel_example = b.addExecutable(.{
        .name = "tunnel-example",
        .root_source_file = b.path("examples/tunnel.zig"),
        .target = target,
        .optimize = optimize,
    });
    tunnel_example.root_module.addImport("wireguard", &lib.root_module);

    const run_tunnel = b.addRunArtifact(tunnel_example);
    const tunnel_step = b.step("example-tunnel", "Run tunnel example");
    tunnel_step.dependOn(&run_tunnel.step);
}
