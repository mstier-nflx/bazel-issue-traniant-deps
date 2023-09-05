load("//build_tools/external_tools:load_tool.bzl", "load_tool")

def load_buildifier():
    load_tool(
        name = "buildifier_darwin_arm64",
        urls = [
            "https://github.com/bazelbuild/buildtools/releases/download/5.0.1/buildifier-darwin-arm64",
        ],
        packaged = False,
        binary_path = "buildifier-darwin-arm64",
        sha256 = "4da23315f0dccabf878c8227fddbccf35545b23b3cb6225bfcf3107689cc4364",
    )
    load_tool(
        name = "buildifier_darwin_x86",
        urls = [
            "https://github.com/bazelbuild/buildtools/releases/download/5.0.1/buildifier-darwin-amd64",
        ],
        packaged = False,
        binary_path = "buildifier-darwin-amd64",
        sha256 = "2cb0a54683633ef6de4e0491072e22e66ac9c6389051432b76200deeeeaf93fb",
    )
    load_tool(
        name = "buildifier_linux_x86",
        urls = [
            "https://github.com/bazelbuild/buildtools/releases/download/5.0.1/buildifier-linux-amd64",
        ],
        packaged = False,
        binary_path = "buildifier-linux-amd64",
        sha256 = "3ed7358c7c6a1ca216dc566e9054fd0b97a1482cb0b7e61092be887d42615c5d",
    )

def load_scalafmt():
    load_tool(
        name = "scalafmt_darwin",
        urls = [
            "https://github.com/scalameta/scalafmt/releases/download/v3.5.1/scalafmt-macos",
        ],
        packaged = False,
        binary_path = "scalafmt-macos",
        sha256 = "cce3b4000643b4f5f759a1ccbd93460c1977f4e4073ba1a7eba6c7174da8dc60",
    )
    load_tool(
        name = "scalafmt_linux_x86",
        urls = [
            "https://github.com/scalameta/scalafmt/releases/download/v3.5.1/scalafmt-linux-musl",
        ],
        packaged = False,
        binary_path = "scalafmt-linux-musl",
        sha256 = "85f18792a241ea322846abe643dfbe8f377952ca862d8126accfd288b0eac6c1",
    )

def load_black():
    load_tool(
        name = "black_macos",
        urls = [
            "https://github.com/psf/black/releases/download/22.3.0/black_macos",
        ],
        packaged = False,
        binary_path = "black_macos",
        sha256 = "ef787f80000f2612a2c7bbf86265b6fccff5cf3c463ea917879ca3e1cc9b0f80",
    )
    load_tool(
        name = "black_linux_u18",
        urls = [
            "https://github.com/aishfenton/black/releases/download/test/black_linux_u18",
        ],
        packaged = False,
        binary_path = "black_linux_u18",
        sha256 = "b261102cdcc426a4131dde476c5fcdba0de829f54fd59df74a6cc8d8cdfc0721",
    )

def load_all_tools():
    load_black()
    load_buildifier()
    load_scalafmt()
