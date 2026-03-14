const std = @import("std");

pub fn build(builder: *std.Build) void {
    std.debug.assert(@sizeOf(std.Build) > 0);
    std.debug.assert(!@inComptime());

    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});
    const noztr_dependency = builder.dependency("noztr", .{});
    const noztr_module = noztr_dependency.module("noztr");
    const smoke_module = builder.createModule(.{
        .root_source_file = builder.path("src/smoke.zig"),
        .target = target,
        .optimize = optimize,
    });
    smoke_module.addImport("noztr", noztr_module);

    const smoke_tests = builder.addTest(.{
        .root_module = smoke_module,
    });

    const run_smoke_tests = builder.addRunArtifact(smoke_tests);
    const test_step = builder.step("test", "Run local noztr consumer smoke tests");
    test_step.dependOn(&run_smoke_tests.step);
}
