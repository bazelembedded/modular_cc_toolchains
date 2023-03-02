load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
package(default_visibility = ["//visibility:public"])

exports_files(glob(["**/*"]))

filegroup(
    name = "all_files",
    srcs = glob(["**/*"]),
)

TOOLS = {
    "cxx": {
        "tool": "//:bin/clang++",
        "data": ["//:cc"],
    },
    "cc": {
        "tool": "//:bin/clang",
        "data": ["//:ld"],
    },
    "ld": {
        "tool": "//:bin/ld.lld",
        "data": [],
    },
    "ar": {
        "tool": "//:bin/llvm-ar",
        "data": [],
    },
    "objdump": {
        "tool": "//:bin/llvm-objdump",
        "data": [],
    },
    "strip": {
        "tool": "//:bin/llvm-strip",
        "data": [],
    },
}

[
    native_binary(
        name = name,
        src = info["tool"],
        data = info["data"],
        out = name,
    )
    for name, info in TOOLS.items()
]
