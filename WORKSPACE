workspace(name = "rule-ts-bug")

load("//build_tools/external_tools:pre_configured_tools.bzl", "load_all_tools")

load_all_tools()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Start bazel-common deps setup as per https://github.com/google/bazel-common/tree/a9e1d8efd54cbf27249695b23775b75ca65bb59d
http_archive(
    name = "google_bazel_common",
    sha256 = "e30e092e50c47a38994334dbe42386675cf519a5e86b973e45034323bbdb70a3",
    strip_prefix = "bazel-common-a9e1d8efd54cbf27249695b23775b75ca65bb59d",
    urls = ["https://github.com/google/bazel-common/archive/a9e1d8efd54cbf27249695b23775b75ca65bb59d.zip"],
)

load("@google_bazel_common//:workspace_defs.bzl", "google_common_workspace_rules")

google_common_workspace_rules()
# End bazel-common deps update.

load("//build_tools/external_tools:version_witness.bzl", _pkg_tar_version_witness = "our_version",ensure_version = "ensure_version")

http_archive(
    name = "rules_pkg",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
    ],
    sha256 = "8f9ee2dc10c1ae514ee599a8b42ed99fa262b757058f65ad3c384289ff70c4b8",
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "build_stack_rules_proto",
    sha256 = "ac7e2966a78660e83e1ba84a06db6eda9a7659a841b6a7fd93028cd8757afbfb",
    strip_prefix = "rules_proto-2.0.1",
    urls = ["https://github.com/stackb/rules_proto/archive/v2.0.1.tar.gz"],
)

# Node JS Setup
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Start aspect_rules_js
http_archive(
    name = "aspect_rules_js",
    sha256 = "7b2a4d1d264e105eae49a27e2e78065b23e2e45724df2251eacdd317e95bfdfd",
    strip_prefix = "rules_js-1.31.0",
    url = "https://github.com/aspect-build/rules_js/releases/download/v1.31.0/rules_js-v1.31.0.tar.gz",
)

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()
# End aspect_rules_js

# Start TypeScript deps setup
http_archive(
    name = "aspect_rules_ts",
    sha256 = "4c3f34fff9f96ffc9c26635d8235a32a23a6797324486c7d23c1dfa477e8b451",
    strip_prefix = "rules_ts-1.4.5",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v1.4.5/rules_ts-v1.4.5.tar.gz",
)

load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies")
#load("@aspect_rules_ts//ts:repositories.bzl", "LATEST_TYPESCRIPT_VERSION")

rules_ts_dependencies(ts_version = "4.9.5")
# End Typescript deps setup

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

# USES 16 version of node.
nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock", "pnpm_repository")

pnpm_repository(name = "pnpm")

npm_translate_lock(
    name = "npm",
    npmrc = "//:.npmrc",
    pnpm_lock = "//:pnpm-lock.yaml",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

http_archive(
    name = "aspect_rules_rollup",
    sha256 = "a0433a0b0206a45d362749d71bc1e4e0dacf5ca2a572b059328f9753392bca80",
    strip_prefix = "rules_rollup-1.0.0",
    url = "https://github.com/aspect-build/rules_rollup/releases/download/v1.0.0/rules_rollup-v1.0.0.tar.gz",
)

load("@aspect_rules_rollup//rollup:dependencies.bzl", "rules_rollup_dependencies")
rules_rollup_dependencies()

http_archive(
    name = "aspect_rules_swc",
    sha256 = "8eb9e42ed166f20cacedfdb22d8d5b31156352eac190fc3347db55603745a2d8",
    strip_prefix = "rules_swc-1.1.0",
    url = "https://github.com/aspect-build/rules_swc/releases/download/v1.1.0/rules_swc-v1.1.0.tar.gz",
)

load("@aspect_rules_swc//swc:dependencies.bzl", "rules_swc_dependencies")

rules_swc_dependencies()

load("@aspect_rules_swc//swc:repositories.bzl", "LATEST_VERSION", "swc_register_toolchains")

swc_register_toolchains(
    name = "swc",
    swc_version = LATEST_VERSION,
)

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")
