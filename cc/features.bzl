"""A set of tools for constructing toolchains features in BUILD files"""

load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureSetInfo",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
)
load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ACTION_NAME_GROUPS",
)

ALL_COMPILE_ACTIONS = ACTION_NAME_GROUPS.all_cc_compile_actions + \
                      ACTION_NAME_GROUPS.all_cpp_compile_actions

ALL_SYSROOT_ACTIONS = ACTION_NAME_GROUPS.all_cc_compile_actions + \
                      ACTION_NAME_GROUPS.all_cc_link_actions + \
                      ACTION_NAME_GROUPS.all_cpp_compile_actions + \
                      ACTION_NAME_GROUPS.cc_link_executable_actions + \
                      ACTION_NAME_GROUPS.dynamic_library_link_actions + \
                      ACTION_NAME_GROUPS.nodeps_dynamic_library_link_actions + \
                      ACTION_NAME_GROUPS.transitive_link_actions

ALL_LINK_ACTIONS = ACTION_NAME_GROUPS.all_cc_link_actions + \
                   ACTION_NAME_GROUPS.cc_link_executable_actions + \
                   ACTION_NAME_GROUPS.dynamic_library_link_actions

# Extracted from: https://bazel.build/docs/cc-toolchain-config-reference#cctoolchainconfiginfo-build-variables
FLAG_VARS = {
    "%{source_file}": ALL_COMPILE_ACTIONS,
    "%{input_file}": ACTION_NAMES.strip,
    "%{output_file}": ALL_COMPILE_ACTIONS,
    "%{output_assembly_file}": ALL_COMPILE_ACTIONS,
    "%{output_preprocess_file}": ALL_COMPILE_ACTIONS,
    "%{dependency_file}": ALL_COMPILE_ACTIONS,
    "%{pic}": ALL_COMPILE_ACTIONS,
    "%{gcov_gcno_file}": ALL_COMPILE_ACTIONS,
    "%{per_object_debug_info_file}": ALL_COMPILE_ACTIONS,
    "%{sysroot}": ALL_SYSROOT_ACTIONS,
    "%{def_file_path}": ALL_LINK_ACTIONS,
    "%{linker_param_file}": ALL_LINK_ACTIONS,
    "%{output_execpath}": ALL_LINK_ACTIONS,
    "%{generate_interface_library}": ALL_LINK_ACTIONS,
    "%{interface_library_builder_path}": ALL_LINK_ACTIONS,
    "%{interface_library_input_path}": ALL_LINK_ACTIONS,
    "%{interface_library_output_path}": ALL_LINK_ACTIONS,
    "%{force_pic}": ALL_LINK_ACTIONS,
    "%{strip_debug_symbols}": ALL_LINK_ACTIONS,
    "%{is_cc_test}": ALL_LINK_ACTIONS,
    "%{is_using_fission}": ALL_LINK_ACTIONS + ALL_LINK_ACTIONS,
    "%{fdo_instrument_path}": ALL_COMPILE_ACTIONS + ALL_LINK_ACTIONS,
    "%{fdo_prefetch_hints_path}": ALL_COMPILE_ACTIONS,
    "%{csfdo_instrument_path}": ALL_COMPILE_ACTIONS + ALL_LINK_ACTIONS,
}

# Extracted from: https://bazel.build/docs/cc-toolchain-config-reference#cctoolchainconfiginfo-build-variables
FLAG_SEQUENCE_VARS = {
    "%{includes}": ALL_COMPILE_ACTIONS,
    "%{include_paths}": ALL_COMPILE_ACTIONS,
    "%{quote_include_paths}": ALL_COMPILE_ACTIONS,
    "%{system_include_paths}": ALL_COMPILE_ACTIONS,
    "%{preprocessor_defines}": ALL_COMPILE_ACTIONS,
    "%{striptopts}": ACTION_NAMES.strip,
    "%{legacy_compile_flags}": ALL_COMPILE_ACTIONS,
    "%{user_compile_flags}": ALL_COMPILE_ACTIONS,
    "%{unfiltered_compile_flags}": ALL_COMPILE_ACTIONS,
    "%{runtime_library_search_directories}": ALL_LINK_ACTIONS,
    "%{library_search_directories}": ALL_LINK_ACTIONS,
    "%{libraries_to_link}": ALL_LINK_ACTIONS,
    "%{legacy_link_flags}": ALL_LINK_ACTIONS,
    "%{user_link_flags}": ALL_LINK_ACTIONS,
    "%{linkstamp_flags}": ALL_LINK_ACTIONS,
}

def action_mux(action_map):
    """ Expands an iterable set of actions that map to a given flag. 

    See cc_feature documentation for example usage.
    """
    action_flags = {}
    for iterable_actions, flags in action_map.items():
        for action in iterable_actions:
            action_flags[action] = action_flags.get(action, []) + flags
    return action_flags

BUILD_VARS_DOC_URL = "https://bazel.build/docs/cc-toolchain-config-reference"

def _extract_build_var_from_flag(flag):
    var_start_index = flag.find("%{")
    if var_start_index == -1:
        return None
    var_end_index = flag.find("}", start = var_start_index)
    if var_end_index == -1:
        fail(
            "In flag '%s' opening variable '%{' was found but got to \
            end of flag and no closing bracket found '}'" % (flag),
        )
    else:
        allowed_in_variable = list("abcdefghijklmnopqrstuvwxyz_".elems())
        flag_name = flag[var_start_index + 2:var_end_index]
        for c in flag_name.elems():
            if c not in allowed_in_variable:
                fail(
                    "Found invalid character: ",
                    c,
                    " in variable.",
                    " The following characters are supported:\n",
                    allowed_in_variable,
                    "See the docs for more information: ",
                    BUILD_VARS_DOC_URL,
                )

        return flag[var_start_index:var_end_index + 1]

def _validate_build_var_with_action(build_var, action, is_iterated = False):
    if is_iterated:
        if build_var not in FLAG_SEQUENCE_VARS.keys():
            fail("Build var '%s' is not found or is not a sequence" % build_var)
    else:
        valid_actions = FLAG_VARS.get(build_var)
        if not valid_actions:
            fail("Build var '%s' is not found or is a sequence, and requires iteration" % build_var)
        if action not in valid_actions:
            fail("Build var is used with unsupported action '%s', the following actions are supported for this build var:\n %s" % (action, valid_actions))

def _action_flags_as_flag_set(action, flags):
    return flag_set(
        actions = [action],
        flag_groups = [flag_group(flags = flags)],
    )

def _cc_feature_impl(ctx):
    runfiles = ctx.runfiles(files = [])
    feature_deps = []
    for dep in ctx.attr.deps:
        runfiles.merge(dep[DefaultInfo].default_runfiles)
        if FeatureSetInfo in dep:
            feature_deps.extend(dep[FeatureSetInfo].features)

    this_feature = feature(
        name = str(ctx.label),
        enabled = ctx.attr.enabled,
        flag_sets = [
            _action_flags_as_flag_set(action, flags)
            for action, flags in ctx.attr.action_flags.items()
        ],
    )
    return [
        feature_set(features = feature_deps + [this_feature]),
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
        "iterative_over_build_var": attr.string(
            doc = "Iterate over a build variable"
        )
    },
    provides = [FeatureSetInfo],
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
