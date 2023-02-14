load(
    "@rules_cc//cc:action_names.bzl", 
    _ACTION_NAME_GROUPS = "ACTION_NAME_GROUPS",
)
ACTION_NAME_GROUPS = struct(
    all_cc_compile_actions = tuple(_ACTION_NAME_GROUPS.all_cc_compile_actions),
    all_cc_link_actions = tuple(_ACTION_NAME_GROUPS.all_cc_link_actions),
    all_cpp_compile_actions = tuple(_ACTION_NAME_GROUPS.all_cpp_compile_actions),
    cc_link_executable_actions = tuple(_ACTION_NAME_GROUPS.cc_link_executable_actions),
    dynamic_library_link_actions = tuple(_ACTION_NAME_GROUPS.dynamic_library_link_actions),
    nodeps_dynamic_library_link_actions = tuple(_ACTION_NAME_GROUPS.nodeps_dynamic_library_link_actions),
    transitive_link_actions = tuple(_ACTION_NAME_GROUPS.transitive_link_actions),
)

