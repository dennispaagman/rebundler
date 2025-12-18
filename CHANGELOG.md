## [Unreleased]

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
