rm -rf ./node_modules
rm -rf ./bar/dist
rm -rf ./bazel-bin/bar
rm -rf ./bar/node_modules

./bazel build bar:dist

