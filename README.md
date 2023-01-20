# modular_cc_toolchains

This is an experimental API for a more modular Bazel toolchain.

**NOTE**: Expect breaking change.

## Goals
A good rundown of why this repository exists is described in the 
[modular cc toolchains proposal](https://docs.google.com/document/d/1-etGNsPneQ8W7MBMxtLloEq-Jj9ng1G-Pip-cWtTg_Y/edit?usp=sharing).

The end goal will be to merge this into the 
[rules_cc repository](https://github.com/bazelbuild/rules_cc). We think that we
can implement the suggested changes without needing to make any breaking changes.
To enforce this we are using a repository structure that mirrors the structure
of rules_cc rather than using a fork. By keeping the structure of the
repository similar to rules_cc we can overlay/merge it into rules_cc with
minimal effort.

## Contributing
Review/issues are welcome, we'd like to keep contributors to a select small team
while we get started. For those, on that team please keep the following in mind;
- Use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)
  so that we can make a nice pretty changelog :)
- Keep the CI in the green as much as possible. This will be enforced soon.
