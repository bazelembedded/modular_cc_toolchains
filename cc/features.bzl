"""A set of tools for constructing toolchains features in BUILD files"""

load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "tool_path",
)

def action_mux(action_map):
    """ Expands an iterable set of actions that map to a given flag. 

    See cc_feature documentation for example usage.
    """
    action_flags = {}
    for iterable_actions, flags in action_map.items():
        for action in iterable_actions:
            action_flags[action] = action_flags.get(action, []) + flags
    return action_flags

def _action_flags_as_flag_set(action, flags):
    return flag_set(
        actions = [action],
        flag_groups = [flag_group(flags = flags)],
    )

def _cc_feature_impl(ctx):
    runfiles = ctx.runfiles(files = [])
    for dep in ctx.attr.deps:
        runfiles.merge(dep[DefaultInfo].default_runfiles)

    return [
        feature(
            name = str(ctx.label),
            enabled = ctx.attr.enabled,
            flag_sets = [
                _action_flags_as_flag_set(action, flags)
                for action, flags in ctx.attr.action_flags.items()
            ],
        ),
        DefaultInfo(
            files = depset(transitive = [
                dep[DefaultInfo].files
                for dep in ctx.attr.deps
            ]),
            runfiles = runfiles,
        ),
    ]

cc_feature = rule(
    _cc_feature_impl,
    attrs = {
        "action_flags": attr.string_list_dict(
            doc = "A mapping of compiler_action[flag_list]",
        ),
        "enabled": attr.bool(
            default = False,
            doc = "Enabled this feature by default.",
        ),
        "doc": attr.string(
            doc = "Description of the purpose of this feature",
        ),
        "deps": attr.label_list(
            doc = "The set of features that this feature implicitly enables/implies.",
        ),
    },
    provides = [FeatureInfo],
    doc = """
Configure a pipeline through each action in the C++ build.

e.g.
```python
# NOTE: @modular_cc_toolchains -> rules_cc if proposal is accepted.
load("@modular_cc_toolchain//cc:features.bzl", "cc_feature")

load("@rules_cc//cc:action_names.bzl", "ALL_CC_COMPILE_ACTION_NAMES", "ALL_CC_LINK_ACTION_NAMES")

cc_feature(
    name = "garbage_collect_sections",
    action_flags = action_mux({
        ALL_CC_COMPILE_ACTION_NAMES: ["-ffunction-sections", "-fdata-sections"],
        ALL_CC_LINK_ACTION_NAMES: ["-Wl,--gc-sections"],
    }),
    doc = "Place each function in it's own section so that the linker can discard unused functions",
)
```
""",
)

CcFeatureSettingInfo = provider(
    doc = """
Specifies a feature mutually exclusive functional feature. e.g.
only one compilation mode feature may be enabled at once, one of;
- opt, 
- dbg, 
- fastbuild
""",
    fields = {
        "name": "The name of the configuration feature, e.g. compilation mode.",
    },
)

def _cc_feature_setting_impl(ctx):
    return [CcFeatureSettingInfo(name = ctx.label.name)]

cc_feature_setting = rule(
    _cc_feature_setting_impl,
)
