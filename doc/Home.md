# Nodaire

Nodaire is a collection of parsers for text file formats.

__Note__: This is a new gem, and the interface is not yet stable.
Expect breaking API changes before v1.0.0 is released.

## File formats

Nodaire provides the following interfaces:

  - Nodaire::Indental for Indental (.ndtl) documents.
  - Nodaire::Tablatal for Tablatal (.tbtl) documents.

## Usage

This document will use Nodaire::Indental as an example.
See the class documentation links above for more examples.

### Parsing Indental

Given the following Indental document:

```
{
  'NAME' => {
    'KEY' => 'VALUE',
    'LIST' => ['ITEM1', 'ITEM2'],
  },
}
```

To parse a string containing this document source:

```ruby
require 'nodaire/indental'

doc = Nodaire::Indental.parse(source)
puts doc.data
```

This will parse the document and convert it to a Ruby hash.

The parser will silently ignore or work around any parser errors, such as
duplicate keys. If you want to raise an exception in this case, replace
`.parse` with `.parse!` in the example above.

<!-- ### Generating Indental -->

## Links

  - [RubyGems.org](https://rubygems.org/gems/nodaire)
  - [View source on GitHub](https://github.com/ljcooke/nodaire)
