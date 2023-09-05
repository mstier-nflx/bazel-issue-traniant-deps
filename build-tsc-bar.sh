rm -rf ./node_modules
rm -rf ./bar/dist
rm -rf ./bazel-bin/bar
rm -rf ./bar/node_modules
rm ./bar/index.js
rm ./bar/tsconfig.tsbuildinfo

./build-foo.sh

yarn install

./node_modules/typescript/bin/tsc -p bar
