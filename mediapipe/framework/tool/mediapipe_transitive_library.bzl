# Presage-specific: helper for collecting transitive C++ proto headers into a
# packageable file set.


def _transitive_protos_with_aggregate_include_impl(ctx):
    """Collects transitive headers from CcInfo deps and emits an aggregate include header."""
    cc_infos = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            cc_infos.append(dep[CcInfo])

    header_paths = []
    headers = []
    found_valid_dep = False
    for cc_info in cc_infos:
        for header in cc_info.compilation_context.direct_headers:
            found_valid_dep = True
            header_paths.append(header.short_path)
            headers.append(header)

    if not found_valid_dep:
        fail(
            "At least one dependency in the dependency tree of all supplied `deps` " +
            "with 'proto_rules' containing 'CcInfo' with headers is required."
        )

    output_aggregate_header = ctx.actions.declare_file(ctx.attr.aggregate_header.name)
    ctx.actions.write(output_aggregate_header, "#include " + "\n#include ".join(header_paths))

    headers.append(output_aggregate_header)

    return [cc_common.merge_cc_infos(cc_infos = cc_infos), DefaultInfo(files = depset(headers))]


transitive_protos_with_aggregate_include = rule(
    implementation = _transitive_protos_with_aggregate_include_impl,
    attrs = {
        "deps": attr.label_list(),
        "aggregate_header": attr.output(mandatory = True),
    },
    provides = [CcInfo],
)
