#!/bin/bash

echo -ne "\033[0;32m"
echo 'Updating bazel dependencies. This will take about five minutes.'
echo -ne "\033[0m"
set -e

BAZEL_DEPS_VERSION="v0.1-19"

if [ "$(uname -s)" == "Linux" ]; then
  PLATFORM_URL_NAME="linux"
elif [ "$(uname -s)" == "Darwin" ]; then
  PLATFORM_URL_NAME="macos"
else
 "Your platform $(uname -s) is unsupported, sorry"
 exit 1
fi
echo "Have fetched bazel deps"

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTS_DIR

REPO_ROOT=$(git rev-parse --show-toplevel)

BAZEL_DEPS_CACHE_ROOT_PATH="$HOME/.cache/.bazel-deps-cache"
BAZEL_DEPS_PATH="$BAZEL_DEPS_CACHE_ROOT_PATH/${BAZEL_DEPS_VERSION}"

cd $REPO_ROOT
set +e
$REPO_ROOT/bazel shutdown &> /tmp/bazel_fe_output_log
if [ "$?" != "0" ]; then
 echo "Bazel command failure, cat produced logs"
 cat /tmp/bazel_fe_output_log
 exit 1
fi
set -e
# Massive churn in the CWD from this whole thing
export DISABLE_BAZEL_FE=true
cd $SCRIPTS_DIR


if [ ! -f ${BAZEL_DEPS_PATH} ]; then
  ( # Opens a subshell
    set -e
    echo "Fetching bazel deps."
    BAZEL_DEPS_URL="https://github.com/bazeltools/bazel-deps/releases/download/${BAZEL_DEPS_VERSION}/bazel-deps-${PLATFORM_URL_NAME}"
    curl -L -o /tmp/bazel-deps-bin $BAZEL_DEPS_URL
    curl -L -o /tmp/bazel-deps-bin.sha256 ${BAZEL_DEPS_URL}.sha256

    BAZEL_DEPS_SHA256=$(cat /tmp/bazel-deps-bin.sha256 | awk '{print $1}')
    GENERATED_SHA_256=$(shasum -a 256 /tmp/bazel-deps-bin | awk '{print $1}')

    if [ "$GENERATED_SHA_256" != "$BAZEL_DEPS_SHA256" ]; then
      echo "Sha 256 does not match, expected: $BAZEL_DEPS_SHA256"
      echo "But found $GENERATED_SHA_256"
      echo "Recommend you:  update the sha to the expected"
      echo "and then re-run this script"
      exit 1
    fi

    chmod +x /tmp/bazel-deps-bin
    mkdir -p "$BAZEL_DEPS_CACHE_ROOT_PATH"
    mv /tmp/bazel-deps-bin ${BAZEL_DEPS_PATH}
  )
fi

cd $REPO_ROOT
set +e

echo "Starting bazel deps resolution"
rm -f tmp__resolved_output.json
rm -f tmp__resolved_output.json.gz

$BAZEL_DEPS_PATH generate -r $REPO_ROOT --resolved-output tmp__resolved_output.json -d dependencies.yaml
RET_CODE=$?
set -e

if [ $RET_CODE == 0 ]; then
  echo "Success, going to upload built files"
else
  echo "Failure, removing generated file"
  cd $REPO_ROOT
  rm tmp__resolved_output.json
  exit $RET_CODE
fi

$BAZEL_DEPS_PATH format-deps -d $REPO_ROOT/dependencies.yaml -o


gzip -n tmp__resolved_output.json
RESOLVED_SIZE=$(ls -lh tmp__resolved_output.json.gz | awk '{print  $5}')
echo "about to push resolved dependencies into CAS. compressed size = ${RESOLVED_SIZE}"
CACHE_SERVER="aebzlremotecache.vip.us-west-2.test.cloud.dead.net:7001"
UPLOADED_URL="$(curl -f ${CACHE_SERVER}/cas --upload-file tmp__resolved_output.json.gz)"
rm -f tmp__resolved_output.json.gz
SHA_V="$(echo $UPLOADED_URL | sed -e 's/\/cas\///' | sed -e 's/\/.*//g')"
echo "pushed to $UPLOADED_URL"

cat << EOM >$REPO_ROOT/3rdparty/third_party_jvm_init.bzl.lockfile
## THIS IS AUTO GENERATED, DO NOT EDIT.
load("//3rdparty:third_party.bzl", "third_party")

def third_party_expansion(name = None):
    if name == None:
      fail("name must be specified")
    third_party(
        name = name,
        urls = [
            "http://${CACHE_SERVER}${UPLOADED_URL}",
        ],
        sha256 = "${SHA_V}"
    )
EOM

echo "All done"
