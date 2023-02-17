workspace(name = "modular_cc_toolchain")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//third_party:test_repos.bzl", "test_repos")

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
    ],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

git_repository(
    name = "rules_cc",
    commit = "42f3259960ba2b7b350bafa50f104567883a49eb",
    remote = "https://github.com/bazelbuild/rules_cc.git",
    shallow_since = "1676631261 -0800",
)

http_archive(
    name = "platforms",
    sha256 = "5308fc1d8865406a49427ba24a9ab53087f17f5266a7aabbfc28823f3916e1ca",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
        "https://github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
    ],
)

test_repos()

http_archive(
    name = "clang_llvm_x86_64_linux_gnu_ubuntu",
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz",
    sha256 = "38bc7f5563642e73e69ac5626724e206d6d539fbef653541b34cae0ba9c3f036",
    build_file = "@//third_party:clang_llvm_x86_64_linux_gnu_ubuntu.BUILD",
    strip_prefix = "clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04",
)
