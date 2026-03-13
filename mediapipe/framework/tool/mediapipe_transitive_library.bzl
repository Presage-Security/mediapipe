# Presage-specific: helper for collecting transitive C++ proto headers into a
# packageable file set.


def _transitive_protos_with_aggregate_include_impl(ctx):
    """Collects transitive headers from CcInfo deps and emits an aggregate include header."""
    cc_infos = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            cc_infos.append(dep[CcInfo])

    # Merge once so transitive header depsets are flattened a single time.
    merged_cc_info = cc_common.merge_cc_infos(cc_infos = cc_infos)

    seen = {}
    header_paths = []
    headers = []
    found_valid_dep = False

    # Collect direct proto headers from immediate deps (covers cc_proto_library
    # deps whose direct_headers include their own .pb.h files).
    for cc_info in cc_infos:
        for header in cc_info.compilation_context.direct_headers:
            sp = header.short_path
            if sp in seen:
                continue
            seen[sp] = True
            found_valid_dep = True
            header_paths.append(sp)
            headers.append(header)

    # Also collect transitive mediapipe proto headers that are missing from
    # direct_headers (e.g. calculator.pb.h, mediapipe_options.pb.h which come
    # from cc_proto_library targets deeper in the dependency graph).
    for header in merged_cc_info.compilation_context.headers.to_list():
        sp = header.short_path
        if sp in seen:
            continue
        if not sp.endswith(".pb.h"):
            continue
        if not ("mediapipe/" in sp):
            continue
        seen[sp] = True
        found_valid_dep = True
        header_paths.append(sp)
        headers.append(header)

    if not found_valid_dep:
        fail(
            "At least one dependency in the dependency tree of all supplied `deps` " +
            "with 'proto_rules' containing 'CcInfo' with headers is required."
        )

    output_aggregate_header = ctx.actions.declare_file(ctx.attr.aggregate_header.name)
    ctx.actions.write(output_aggregate_header, "#include " + "\n#include ".join(header_paths))

    headers.append(output_aggregate_header)

    return [merged_cc_info, DefaultInfo(files = depset(headers))]


transitive_protos_with_aggregate_include = rule(
    implementation = _transitive_protos_with_aggregate_include_impl,
    attrs = {
        "deps": attr.label_list(),
        "aggregate_header": attr.output(mandatory = True),
    },
    provides = [CcInfo],
)
