# Presage-specific: for transitive protobuf C++ dependencies
load("//mediapipe/framework:transitive_protos.bzl", "proto_rules_aspect", "transitive_protos")

def _transitive_protos_with_aggregate_include_impl(ctx):
    """Implementation of transitive_protos_with_header_list rule.

    Args:
      ctx: The rule context.
    Returns:
      A proto provider (with transitive_sources and transitive_descriptor_sets filled in),
      and marks all transitive sources as default output.
    """
    cc_info_sets = []

    for dep in ctx.attr.deps:
        cc_info_sets.append(dep.proto_rules)
    cc_infos = depset(transitive = cc_info_sets).to_list()

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

    output_aggregate_header = ctx.actions.declare_file(ctx.attr.aggregate_header.name)
    ctx.actions.write(output_aggregate_header, "#include " + "\n#include ".join(header_paths))

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
