#!/bin/bash

if [ -z "${REPO_ROOT:-}" ];then
  # This file is sourced, so you can't do bash source stuff here.
  export REPO_ROOT="$(git rev-parse --show-toplevel)"
fi

BAZEL_FE_VERSION=v0.1-340
BUILDOZER_VERSION=5.1.0

if [ -z "${BAZEL_FE_INDEX_LOCATION:-}" ]; then
  export INDEX_INPUT_LOCATION=/tmp/bazelfe_current_index
else
  export INDEX_INPUT_LOCATION=$BAZEL_FE_INDEX_LOCATION
fi
DAEMON_NAME_SECTION=""
if [ -n "${BAZELFE_INCLUDE_DAEMON:-}" ]; then
  DAEMON_NAME_SECTION="-with-daemon"
fi

TMPDIR="${TMPDIR:-/tmp}"

if [ "$(uname -s)" == "Linux" ]; then
  export BAZEL_FE_PLATFORM_NAME='linux-ubuntu-18.04'
  export BUILDIFIER_PLATFORM_SUFFIX="-linux-amd64"
elif [ "$(uname -s)" == "Darwin" ]; then
  ARCH="$(uname -m)"
  if [ "$ARCH" == "arm64" ]; then
    export BAZEL_FE_PLATFORM_NAME='macos-arm64'
    export BUILDIFIER_PLATFORM_SUFFIX="-darwin-arm64"
  else
    export BAZEL_FE_PLATFORM_NAME='macos'
    export BUILDIFIER_PLATFORM_SUFFIX="-darwin-amd64"
  fi
else
  "Your platform $(uname -s) is unsupported, sorry"
  exit 1
fi

if [ -z "${BAZEL_FE_TOOLS:-}" ]; then
  BAZEL_FE_TOOLS=~/.bazelfe_tools
fi
mkdir -p "$BAZEL_FE_TOOLS"

BAZEL_RUNNER_URL=https://github.com/bazeltools/bazelfe/releases/download/${BAZEL_FE_VERSION}/bazel-runner${DAEMON_NAME_SECTION}-${BAZEL_FE_PLATFORM_NAME}
BAZEL_RUNNER_SHA_URL=https://github.com/bazeltools/bazelfe/releases/download/${BAZEL_FE_VERSION}/bazel-runner${DAEMON_NAME_SECTION}-${BAZEL_FE_PLATFORM_NAME}.sha256
BAZEL_RUNNER_LOCAL_PATH="${BAZEL_FE_TOOLS}/bazel-runner${DAEMON_NAME_SECTION}-${BAZEL_FE_VERSION}"

JVM_INDEXER_URL=https://github.com/bazeltools/bazelfe/releases/download/${BAZEL_FE_VERSION}/jvm-indexer${DAEMON_NAME_SECTION}-${BAZEL_FE_PLATFORM_NAME}
JVM_INDEXER_SHA_URL=https://github.com/bazeltools/bazelfe/releases/download/${BAZEL_FE_VERSION}/jvm-indexer${DAEMON_NAME_SECTION}-${BAZEL_FE_PLATFORM_NAME}.sha256
JVM_INDEXER_LOCAL_PATH="${BAZEL_FE_TOOLS}/jvm-indexer${DAEMON_NAME_SECTION}-${BAZEL_FE_VERSION}"
BUILDOZER_URL=https://github.com/bazelbuild/buildtools/releases/download/${BUILDOZER_VERSION}/buildozer${BUILDIFIER_PLATFORM_SUFFIX}
BUILDOZER_SHA_URL=""
BUILDOZER_LOCAL_PATH="${BAZEL_FE_TOOLS}/buildozer-${BUILDOZER_VERSION}"

BAZEL_CFG_N=1
REPO_NAME=$(basename $REPO_ROOT)
if [ -n "$HOME" ]; then
  DEP_TRACKING_FOLDER="${HOME}/.cache/bazel_${REPO_NAME}_dep_tracking"
else
  # Some sort of special containerized or other env, just use tmp.
  DEP_TRACKING_FOLDER="/tmp/bazel_${REPO_NAME}_dep_tracking"
fi

if [ ! -d "${DEP_TRACKING_FOLDER}" ]; then
  mkdir -p "${DEP_TRACKING_FOLDER}"
fi

BAZELFE_CONFIG_PATH="$REPO_ROOT/build_tools/bazelfe/config"

BAZEL_CFG_N_PATH="${DEP_TRACKING_FOLDER}/cfg_${BAZEL_CFG_N}"

function fetch_binary() {
  TARGET_PATH="$1"
  FETCH_URL="$2"
  URL_SHA="$3"
  set +e

  # Ocassionally github has returned invalid data, even though it wasn't a 500.

  fetch_binary_inner "$TARGET_PATH" "$FETCH_URL" "$URL_SHA"
  RET="$?"
  if [ "$RET" == "0" ]; then
    return
  fi
  echo "Tool failed to download from upstream. Probably transient, will retry. Sleep 20 seconds"
  sleep 20


  fetch_binary_inner "$TARGET_PATH" "$FETCH_URL" "$URL_SHA"
  RET="$?"
  if [ "$RET" == "0" ]; then
    return
  fi
  echo "Tool failed to download from upstream. Probably transient, will retry. Sleep 20 seconds"
  sleep 20

  # Final attempt, just pass through the error code from the inner call.
  set -e
  fetch_binary_inner "$TARGET_PATH" "$FETCH_URL" "$URL_SHA"
}

function fetch_binary_inner() {
  RND_UID="${USER}_$(date "+%s")_${RANDOM}_${RANDOM}"
  export BUILD_DIR=${TMPDIR}/bazel_b_${RND_UID}
  mkdir -p $BUILD_DIR

  TARGET_PATH="$1"
  FETCH_URL="$2"
  URL_SHA="$3"
  set +e
  which shasum &> /dev/null
  HAVE_SHASUM=$?
  set -e
  if [ ! -f $TARGET_PATH ]; then
    echo "Need to fetch new copy of tool, fetching... ${FETCH_URL}"
    ( # Opens a subshell
      set -e
      cd $BUILD_DIR

      curl -o tmp_download_file -L $FETCH_URL
      chmod +x tmp_download_file


      if [ "$HAVE_SHASUM" == "0" ]; then
        if [ -n "$URL_SHA" ]; then
          curl -s --show-error -o tmp_download_file_SHA -L $URL_SHA
          GENERATED_SHA_256=$(shasum -a 256 tmp_download_file | awk '{print $1}')

          if [ "$GENERATED_SHA_256" != "$(cat tmp_download_file_SHA)" ]; then
            echo "when working on tool: $TARGET_PATH"
            echo "Sha 256 does not match, expected: $(cat tmp_download_file_SHA) downloaded from ${URL_SHA}"
            echo "But found $GENERATED_SHA_256"
            echo "Probably bad download."
            exit 1
          fi
        fi
      fi

      mv tmp_download_file "$TARGET_PATH"
    )
    rm -rf $BUILD_DIR
  fi
}
