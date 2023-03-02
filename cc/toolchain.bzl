load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "FeatureSetInfo", "tool_path")

# We are going to use action_confgs for everything as an alternative to
# using tool_paths which just add unneccesary confusion.
_NULL_TOOL_PATHS = [
    tool_path(
        name = "gcc",
        path = "/usr/bin/clang",
    ),
    tool_path(
        name = "ld",
        path = "/usr/bin/ld",
    ),
    tool_path(
        name = "ar",
        path = "/bin/false",
    ),
    tool_path(
        name = "cpp",
        path = "/bin/false",
    ),
    tool_path(
        name = "gcov",
        path = "/bin/false",
    ),
    tool_path(
        name = "nm",
        path = "/bin/false",
    ),
    tool_path(
        name = "objdump",
        path = "/bin/false",
    ),
    tool_path(
        name = "strip",
        path = "/bin/false",
    ),
]

def _toolchain_config_impl(ctx):
    features = []
    for feature in ctx.attr.features:
        features.extend(feature[FeatureSetInfo].features)

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,  # NEW
        # Unused let features handle this.
        cxx_builtin_include_directories = [],
        tool_paths = _NULL_TOOL_PATHS,

        # TODO: Do we actually need any of these?
        toolchain_identifier = "local",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "unknown",
        target_libc = "unknown",
        compiler = "unknown",
        abi_version = "unknown",
        abi_libc_version = "unknown",
    )

cc_toolchain_config = rule(
    _toolchain_config_impl,
    attrs = {
        "cc_features": attr.label_list(
            doc = "The list of cc_features to include in this toolchain.",
            mandatory = True,
            providers = [FeatureSetInfo],
        ),
        "action_configs": attr.label_list(
            doc = "The list of cc_action_configs to include in this toolchain.",
            mandatory = True,
        ),
    },
    provides = [CcToolchainConfigInfo],
)
