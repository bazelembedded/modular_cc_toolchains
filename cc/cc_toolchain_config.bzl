load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "FeatureSetInfo", "feature")
load("//cc:actions.bzl", "ActionConfigSetInfo")

# TODO(#12): This probably shouldn't exist.
# There are some quirks in how some features are enabled/disabled based on tool_paths.
# As we don't use tool_paths, we need to reimplement some of these quirks?
_QUIRKY_FEATURES = [
    feature(
        name = "quirk_enable_archiver_flags",
        enabled = True,
        implies = ["archiver_flags"],
    )
]

def _cc_toolchain_config_impl(ctx):
    runfiles = ctx.runfiles()
    transitive_files = []

    # Flatten action_configs
    action_configs = []
    for action_config_set in ctx.attr.action_configs:
        action_configs += action_config_set[ActionConfigSetInfo].configs
        runfiles = runfiles.merge_all([action_config_set[DefaultInfo].default_runfiles])
        transitive_files.append(action_config_set[DefaultInfo].files)

    # Deduplicate features
    action_configs = depset(action_configs).to_list()

    # Flatten features
    features = []
    for feature_set in ctx.attr.cc_features:
        features += feature_set[FeatureSetInfo].features
        runfiles = runfiles.merge_all([feature_set[DefaultInfo].default_runfiles])
        transitive_files.append(feature_set[DefaultInfo].files)

    # Deduplicate features
    features = depset(features).to_list()

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "local",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        action_configs = action_configs,
        features = features + _QUIRKY_FEATURES,
        cxx_builtin_include_directories = ctx.attr.cxx_builtin_include_directories,
    )

cc_toolchain_config = rule(
    _cc_toolchain_config_impl,
    attrs = {
        "cc_features": attr.label_list(
            doc = "A list of features to include in the toolchain",
            providers = [FeatureSetInfo],
        ),
        "action_configs": attr.label_list(
            doc = "A list of action_configs to include in the toolchain",
            providers = [ActionConfigSetInfo],
            mandatory = True,
        ),
        # TODO(#11): We shouldn't allow this, hard coded system libs make it
        # harder to create hermetic toolchains. This should be removed
        # before we release the modular toolchains api.
        "cxx_builtin_include_directories": attr.string_list(
            doc = "A list of system libraries to include",
        ),
    },
)
