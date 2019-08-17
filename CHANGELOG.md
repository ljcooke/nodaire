# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased] -->

## [0.2.0] - 2019-08-17
### Added
- Parse [Indental](https://wiki.xxiivv.com/#indental) files,
  returning a hash or a JSON string.
- `#valid?` and `#errors` instance methods.

### Changed
- `.parse` silently ignores duplicate keys and other errors, instead of raising
  an exception. This is paired with a new `.parse!` method which _does_ raise
  an exception.

## [0.1.0] - 2019-08-16
### Added
- Parse [Tablatal](https://wiki.xxiivv.com/#tablatal) files,
  returning an array of hashes or a CSV string.

[Unreleased]: https://github.com/ljcooke/nodaire/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/ljcooke/nodaire/releases/tag/v0.2.0
[0.1.0]: https://github.com/ljcooke/nodaire/releases/tag/v0.1.0
