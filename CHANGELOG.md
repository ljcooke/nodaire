# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Support for Indental keys with blank values.
- Two string normalization methods are now public: `Nodaire.squeeze` and
  `Nodaire.symbolize`.

### Changed
- Category names and keys are converted to upper case.
- Any sequence of whitespace is converted into a space character. Punctuation
  is left intact.
- `symbolize_names` converts any sequence of non-alphanumeric characters to `_`.

### Fixed
- Indentation using tabs is now treated as an error.

## [0.3.0] - 2019-08-18
### Added
- `Indental#categories` returns an array of category names.
- [Documentation!](https://slisne.github.io/nodaire/)

### Changed
- Strings are used for keys by default. To use symbols, pass the
  `symbolize_names` argument.
- Category names and keys are normalised when detecting duplicates, and when
  converting them to symbols. This involves converting to lowercase and
  replacing each sequence of whitespace/underscores/dashes with `_`.
- Indental parser detects when the input is wrapped in a JS template string.
- Require Ruby >= 2.5.0. (Previously there was no minimum set, but it used
  a feature that required Ruby >= 2.6.0.)

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

[Unreleased]: https://github.com/ljcooke/nodaire/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/ljcooke/nodaire/releases/tag/v0.3.0
[0.2.0]: https://github.com/ljcooke/nodaire/releases/tag/v0.2.0
[0.1.0]: https://github.com/ljcooke/nodaire/releases/tag/v0.1.0
