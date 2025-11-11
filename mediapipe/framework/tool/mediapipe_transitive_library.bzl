# Presage-specific: for transitive protobuf C++ dependencies
load("//mediapipe/framework:transitive_protos.bzl", "transitive_protos")

# Provider for carrying CcInfo across the aspect
_ProtoRulesInfo = provider(
    "ProtoRulesInfo",
    fields = ["cc_info"],
)

def _proto_rules_aspect_impl(target, ctx):
    """Aspect implementation that collects CcInfo from proto dependencies."""
    cc_info = None

    # Check if target has CcInfo (proto_library with cc_proto_library)
    if CcInfo in target:
        cc_info = target[CcInfo]

    # Collect CcInfo from dependencies
    deps = []
    if hasattr(ctx.rule.attr, "deps"):
        for dep in ctx.rule.attr.deps:
            if _ProtoRulesInfo in dep and dep[_ProtoRulesInfo].cc_info:
                deps.append(dep[_ProtoRulesInfo].cc_info)

    # Merge all CcInfo
    if cc_info:
        deps.append(cc_info)

    merged_cc_info = cc_common.merge_cc_infos(cc_infos = deps) if deps else None

    return [_ProtoRulesInfo(cc_info = merged_cc_info)]

proto_rules_aspect = aspect(
    implementation = _proto_rules_aspect_impl,
    attr_aspects = ["deps"],
)

def _transitive_protos_with_aggregate_include_impl(ctx):
    """Implementation of transitive_protos_with_header_list rule.

    Args:
      ctx: The rule context.
    Returns:
      A proto provider (with transitive_sources and transitive_descriptor_sets filled in),
      and marks all transitive sources as default output.
    """
    cc_infos = []

    for dep in ctx.attr.deps:
        if _ProtoRulesInfo in dep and dep[_ProtoRulesInfo].cc_info:
            cc_infos.append(dep[_ProtoRulesInfo].cc_info)

    header_paths = []
    headers = []
    found_valid_dep = False
    for cc_info in cc_infos:
        for header in cc_info.compilation_context.direct_headers:
            found_valid_dep = True
            header_paths.append(header.short_path)
            headers.append(header)

    if not found_valid_dep:
        fail("At least one dependency in the dependency tree of all supplied `deps` with 'proto_rules' containing" +
             "'CcInfo' with headers is required.")

    output_aggregate_header = ctx.outputs.aggregate_header
    includes = ['#include "{}"'.format(path) for path in header_paths]
    ctx.actions.write(output_aggregate_header, "\n".join(includes))

    headers.append(output_aggregate_header)

    return [cc_common.merge_cc_infos(cc_infos = cc_infos), DefaultInfo(files = depset(headers))]

transitive_protos_with_aggregate_include = rule(
    implementation = _transitive_protos_with_aggregate_include_impl,
    attrs =
        {
            "deps": attr.label_list(
                aspects = [proto_rules_aspect],
            ),
            "aggregate_header": attr.output(mandatory = True),
        },
    provides = [CcInfo],
)

def mediapipe_cc_shared_library(name, deps = [], testonly = False, **kwargs):
    transitive_protos_with_aggregate_include(
        name = name + "_cc_protos",
        aggregate_header = name + "_cc_protos.h",
        deps = deps,
        testonly = testonly,
    )

    native.cc_library(
        name = name + "_cc_protos_library",
        deps = [name + "_cc_protos"],
        testonly = testonly,
    )

    native.cc_shared_library(
        name = name,
        deps = deps + [name + "_cc_protos_library"],
        testonly = testonly,
        **kwargs
    )
