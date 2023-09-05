#!/bin/bash
set -e

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export REPO_ROOT="$(cd $TOOLS_DIR && cd .. && cd .. && pwd)"

$REPO_ROOT/bazel shutdown
export DISABLE_BAZEL_FE=true

source $REPO_ROOT/build_tools/bazelfe/common.sh

1>&2 fetch_binary "$JVM_INDEXER_LOCAL_PATH" "$JVM_INDEXER_URL" "$JVM_INDEXER_SHA_URL"

RUST_LOG="info,bazelfe_core=info,jvm_indexer=info" exec "$JVM_INDEXER_LOCAL_PATH" --config "$BAZELFE_CONFIG_PATH" --index-output-location ${INDEX_INPUT_LOCATION} --bazel-binary-path "$REPO_ROOT/bazel" --blacklist-remote-roots pip_,io_bazel_rules_scala,remote_jdk8_macos_x86,has_android_sdk,databinding_annotation_processor,rules_java,com_github_bazelbuild_buildtools,com_github_bazelbuild_rules_go,rules_go,com_github_census_instrumentation_opencensus_proto,remotejdk,android,scalafmt_,buildifier_,bazel_gazelle --bazel-deps-root "@third_party_jvm" $@