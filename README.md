# Basic Template

[![Lint Code Base](https://github.com/pacroy/template-basic/actions/workflows/linter.yml/badge.svg)](https://github.com/pacroy/template-basic/actions/workflows/linter.yml) [![Check Markdown Links](https://github.com/pacroy/template-basic/actions/workflows/markdown-link-check.yml/badge.svg)](https://github.com/pacroy/template-basic/actions/workflows/markdown-link-check.yml)

## Features Included

- GitHub Actions Workflows
  - [linter.yml] - [Superlinter]
  - [check-md-links.yml] - [Markdown Link Checker]

## Usage

1. Click <kbd>Use this template</kbd> to [create a new repository from this template].
2. Update [linter.yml] or remove if you don't need it.

- [Create repository secret] `LINTER_VALIDATE_ALL_CODEBASE` and set to `true` if you want superlinter to always scan all codebase. Otherwise, set to `false` to scan only those changed.
- Update or remove environment variables in `Lint Code Base` step as you wish. See comments for how to customize each of them.

3. Update the following [default linter's configurations] in [.github/linters] folder or remove them to always use the default configuration.

- Customize [.markdown-lint.yml] for Markdown linter. See [MarkdownLint Configuration] for more detail.
- Customize [.hadolint.yaml] for dockerfile linter. See [Haskell Dockerfile Linter Configuration] for more detail.
- Customize [.dockerfilelintrc] for dockerfile linter. See [DockerfileLint Configuration] for more detail.
- Customize [.jscpd.json] for copy/paste detector check.

4. Remove [markdown-link-check.yml] if you don't need it. Otherwise, update [mlc_config.json] to exclude some private URLs.
5. Update [README.md] accordingly. Don't forget to update the status badges to point to your repository.

[Superlinter]: <https://github.com/github/super-linter>
[linter.yml]: <.github/workflows/linter.yml>
[create a new repository from this template]: <https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/creating-a-repository-from-a-template>
[Create repository secret]: <https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository>
[.markdown-lint.yml]: <.github/linters/.markdown-lint.yml>
[.hadolint.yaml]: <.github/linters/.hadolint.yaml>
[MarkdownLint Configuration]: <https://github.com/igorshubovych/markdownlint-cli#configuration>
[.jscpd.json]: <.github/linters/.jscpd.json>
[.github/linters]: <.github/linters>
[.dockerfilelintrc]: <.github/linters/.dockerfilelintrc>
[DockerfileLint Configuration]: <https://github.com/replicatedhq/dockerfilelint#configuring>
[Haskell Dockerfile Linter Configuration]: <https://github.com/hadolint/hadolint#configure>
[default linter's configurations]: <https://github.com/github/super-linter/tree/master/TEMPLATES>
[Markdown Link Checker]: <https://github.com/tcort/markdown-link-check#config-file-format>
[markdown-link-check.yml]: <.github/workflows/markdown-link-check.yml>
[mlc_config.json]: <.github/markdown-link-check/mlc_config.json>
[README.md]: <README.md>