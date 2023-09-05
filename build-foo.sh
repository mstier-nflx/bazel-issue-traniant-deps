rm -rf ./foo/dist
rm -rf ./bazel-bin/foo
rm -rf ./node_modules
./bazel build //foo:dist

chmod -R 755 bazel-bin/foo
cp -r bazel-bin/foo/ foo/dist
chmod -R 755 foo/dist