# bazel-issue-ts-typechecking

To reproduce typechecking error, run ./build-bazel-bar.sh
Look at bazel-bin/bar/types/index.d.ts

Compare to ./build-tsc-bar.sh
Look at bar/dist/types/index.d.ts

They produce different index.d.ts files and Bazel is more permissive.