load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def test_repos():
    """ Pulls in dev dependencies to test the compiler against

    These dependencies are included for testing toolchains and are not required
    for general usage.
    """

    if "bazel_skylib" not in native.existing_rules():
        http_archive(
            name = "bazel_skylib",
            sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            ],
        )

    if "rules_python" not in native.existing_rules():
        http_archive(
            name = "rules_python",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.5.0/rules_python-0.5.0.tar.gz",
            sha256 = "cd6730ed53a002c56ce4e2f396ba3b3be262fd7cb68339f0377a45e8227fe332",
        )

    if "com_google_googletest" not in native.existing_rules():
        http_archive(
            name = "com_google_googletest",
            sha256 = "ad7fdba11ea011c1d925b3289cf4af2c66a352e18d4c7264392fead75e919363",
            strip_prefix = "googletest-1.13.0",
            urls = ["https://github.com/google/googletest/archive/refs/tags/v1.13.0.tar.gz"],
        )

    if "com_github_google_benchmark" not in native.existing_rules():
        http_archive(
            name = "com_github_google_benchmark",
            strip_prefix = "benchmark-1.6.0",
            urls = ["https://github.com/google/benchmark/archive/v1.6.0.tar.gz"],
        )

    if "com_google_absl" not in native.existing_rules():
        http_archive(
            name = "com_google_absl",
            sha256 = "91ac87d30cc6d79f9ab974c51874a704de9c2647c40f6932597329a282217ba8",
            urls = ["https://github.com/abseil/abseil-cpp/archive/refs/tags/20220623.1.tar.gz"],
            strip_prefix = "abseil-cpp-20220623.1",
        )

    if "com_google_protobuf" not in native.existing_rules():
        http_archive(
            name = "com_google_protobuf",
            sha256 = "87407cd28e7a9c95d9f61a098a53cf031109d451a7763e7dd1253abf8b4df422",
            strip_prefix = "protobuf-3.19.1",
            urls = [
                "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/v3.19.1.tar.gz",
                "https://github.com/protocolbuffers/protobuf/archive/v3.19.1.tar.gz",
            ],
        )
    if "com_googlesource_code_re2" not in native.existing_rules():
        http_archive(
            name = "com_googlesource_code_re2",
            sha256 = "b885bb965ab4b6cf8718bbb8154d8f6474cd00331481b6d3e390babb3532263e",
            strip_prefix = "re2-e860767c86e577b87deadf24cc4567ea83c4f162/",
            urls = ["https://github.com/google/re2/archive/e860767c86e577b87deadf24cc4567ea83c4f162.zip"],
        )
