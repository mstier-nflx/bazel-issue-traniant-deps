#!/bin/bash

#This is a wrapper that runs update_dependencies.sh only if there are dependency lock file changes
CHANGED_DEPENDENCY_LOCK_FILES=`git diff --name-only | grep "dependencies.lock"`
if [ -z "$CHANGED_DEPENDENCY_LOCK_FILES" ]
then
  echo "Dependency lock files have not changed, not updating bazel deps."
else
  echo "Dependency lock files changed, updating bazel deps."
  REPO_ROOT=$(git rev-parse --show-toplevel)
  cd $REPO_ROOT
  ./build_tools/dependencies/update_dependencies.sh
fi