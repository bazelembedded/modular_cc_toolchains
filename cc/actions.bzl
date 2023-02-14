load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "action_config", "tool")
load("//cc:features.bzl", "cc_feature")

def _action_config_impl(ctx):
    tool_symlink = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output=tool_symlink, 
                        target_file=ctx.executable.tool, 
                        is_executable=True)
    runfiles = ctx.runfiles(files = [tool_symlink])
    runfiles = runfiles.merge_all([ctx.attr.tool[DefaultInfo].default_runfiles] + 
                [dep[DefaultInfo].default_runfiles for dep in ctx.attr.deps])
    return [
        # TODO(#4): Confirm this still works when bazelbuild/rules_cc#72 is 
        # merged.
        action_config(
            action_name = ctx.attr.action_name,
            enabled = ctx.attr.enabled,
            tools = [tool(tool = ctx.executable.tool)],
        ),
        DefaultInfo(
            executable = tool_symlink,
            runfiles = runfiles,            
            files = depset([tool_symlink])
        )
    ]


_cc_action_config = rule(
    _action_config_impl,
    attrs = {
        "action_name" : attr.string(
            doc = "The action name to configure the tool paths",
        ),
        "tool": attr.label(
            doc = "The tool to use for this action.",
            executable = True,
            mandatory = True,
            cfg = "exec",
            allow_single_file = True,
        ),
        "enabled": attr.bool(
            doc = "Enables this action_config by default.",
            default = False,
        ),
        "deps": attr.label_list(
            doc = "The list of features and actions that this action enables."
        )
    },
    doc = "Maps a tool onto a specific action in a cc toolchain.",
    executable = True,
)

def cc_action_config(**kwargs):
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
            **kwargs,
        )
    # This is a top level feature that is used to enable the iterated action_configs.
    cc_feature(
        name = name,
        deps = ["{}.{}".format(name, action_name) 
                for action_name in action_tools.keys()] + deps,
        **kwargs,
    )
