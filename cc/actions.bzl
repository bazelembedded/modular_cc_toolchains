load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "action_config", "tool")

def action_tool_mux(action_tool_mapping):
    result = {}
    for actions, tool in action_tool_mapping.items():
        if type(actions) == type(""):
            result[actions] = tool
        elif type(actions) == type(()):
            for action in actions:
                result[action] = tool
        else:
            fail("Unsupported key-type, got type:{}, wanted string or tuple of strings".format(type(actions)))
    return result

ActionConfigSetInfo = provider(
    doc = "A set of action_configs",
    fields = {
        "configs": "A set of action configs",
    },
)

def _action_config_impl(ctx):
    dependant_action_configs = []
    for dep in ctx.attr.deps:
        dependant_action_configs += dep[ActionConfigSetInfo].configs

    if ctx.attr.tool:
        tool_symlink = ctx.actions.declare_file(ctx.label.name)
        ctx.actions.symlink(
            output = tool_symlink,
            target_file = ctx.executable.tool,
            is_executable = True,
        )
        tool_runfiles = [ctx.attr.tool[DefaultInfo].default_runfiles]
        tool_symlink = [tool_symlink]
    else:
        tool_runfiles = []
        tool_symlink = []
    runfiles = ctx.runfiles(files = tool_symlink)
    runfiles = runfiles.merge_all(tool_runfiles +
                                  [dep[DefaultInfo].default_runfiles for dep in ctx.attr.deps])
    configs = []
    if ctx.executable.tool:
        configs.append(action_config(
            action_name = ctx.attr.action_name,
            enabled = ctx.attr.enabled,
            tools = [tool(tool = ctx.executable.tool)],
        ))
    return [
        # TODO(#4): Confirm this still works when bazelbuild/rules_cc#72 is
        # merged.
        ActionConfigSetInfo(
            configs = configs + dependant_action_configs,
        ),
        DefaultInfo(
            runfiles = runfiles,
            files = depset(
                tool_symlink,
                transitive = [
                    dep[DefaultInfo].files
                    for dep in ctx.attr.deps
                ],
            ),
        ),
    ]

_cc_action_config = rule(
    _action_config_impl,
    attrs = {
        "action_name": attr.string(
            doc = "The action name to configure the tool paths",
        ),
        "tool": attr.label(
            doc = "The tool to use for this action.",
            executable = True,
            cfg = "exec",
            allow_single_file = True,
        ),
        "enabled": attr.bool(
            doc = "Enables this action_config by default.",
            default = False,
        ),
        "deps": attr.label_list(
            doc = "The list of features and actions that this action enables.",
        ),
    },
    doc = "Maps a tool onto a specific action in a cc toolchain.",
    provides = [ActionConfigSetInfo],
)

def cc_action_config(**kwargs):
    # NOTE: Under the current action_config macros we can only specify one action name per
    # action_config. This leads to a lot of uneccesary boiler plate, this rule + macro
    # allows us to bundle up a set of action_configs so that we can map multiple
    # tools->actions.
    action_tools = kwargs.pop("action_tools")
    name = kwargs.pop("name")
    deps = kwargs.pop("deps", [])
    for action_name, tool in action_tools.items():
        _cc_action_config(
            name = "{}.{}".format(name, action_name),
            tool = tool,
            action_name = action_name,
            # Keep these subtargets disabled and we will implicitly enabled them
            # using the top-level deps.
            enabled = False,
            deps = deps,
            **kwargs
        )

    # This is a top level feature that is used to enable the iterated action_configs.
    _cc_action_config(
        name = name,
        deps = [
            "{}.{}".format(name, action_name)
            for action_name in action_tools.keys()
        ] + deps,
        **kwargs
    )
