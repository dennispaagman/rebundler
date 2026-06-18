## [0.6.1] - 2026-06-18

- Include pre-release versions when fetching external gem info, so gems published only
  as pre-releases (e.g. `typesense-rails`) are found and get a generated trailing
  comment. Stable gems still resolve to their latest stable version.

## [0.6.0] - 2026-06-18

- Add support for the `install_if` directive. `install_if` blocks are now parsed and
  formatted like other directive blocks (`group`, `path`, etc.).
- Fixed a crash when a block was empty.
- Fall back to a gem's `description` when its `summary` is `nil` or blank, so the
  generated trailing comment is still populated.
- Declare `prism` and `zeitwerk` as runtime dependencies in the gemspec (they were
  previously only in the Gemfile), fixing standalone installs of the gem.
- Internal refactoring (inlined the summarizer into `GemDeclaration`) and dependency updates.

## [0.5.1] - 2026-03-13

- Remove references to running as a bundler plugin. This does not work well, so decided to remove it.
- Fixed Ruby 3.3 support.

## [0.5.0] - 2026-03-13

- Major internal refactor and clean up.

  You can now instantiate the parser via `Rebundler::Parser.from_file(path)` or directly
  from a string via `Rebundler::Parser.from_string(content)`.

## [0.4.0] - 2025-12-21

- **Breaking** Rebundler now leaves existing trailing comments intact.

  You can still overwrite them (the previous behavior) by using the `--force` flag.

## [0.3.1] - 2025-12-19

- Fixed bug where comment on last gem in a block was not overwritten.

## [0.3.0] - 2025-12-18

- Add support for tabs instead of spaces.
- Add support for `git_source`.
- Some refactoring.

## [0.2.0] - 2025-12-06

Notable changes:

- Add CI mode.

  If you run `bundle exec rebundle --ci`, rebundler will run in CI mode, which will compare the output
  of the current Gemfile to a freshly formatted one. If there are differences, rebundler will exit
  with a non-zero status code. This does not write to the Gemfile.

- Major internal refactor.

## [0.1.3] - 2025-09-09

Notable changes:

- Merge equal groups into each other.

## [0.1.2] - 2025-09-09

Notable changes:

- Ignore dashes and underscores when sorting gems.

## [0.1.1] - 2025-09-09

No notable changes.

## [0.1.0] - 2024-11-17

Initial release.
