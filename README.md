# Nodaire

Nodaire is a collection of parsers for text file formats.

__Note__: This is a new gem, and the interface is not yet stable.
Expect breaking API changes before v1.0.0 is released.

[![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire)
[![Build Status](https://travis-ci.org/slisne/nodaire.svg?branch=master)](https://travis-ci.org/slisne/nodaire)

## File formats

Nodaire currently supports the following text file formats:

| Format | `.parse` | `.generate` |
|---|---|---|
| [Indental](https://wiki.xxiivv.com/#indental) (.ndtl) | YES | no |
| [Tablatal](https://wiki.xxiivv.com/#tablatal) (.tbtl) | YES | no |

## Examples

### Indental

```ruby
require 'nodaire/indental'

doc = Nodaire::Indental.parse! <<~NDTL
  {
    'NAME' => {
      'KEY' => 'VALUE',
      'LIST' => ['ITEM1', 'ITEM2'],
    },
  }
NDTL

doc.valid?     # true
doc.categories # ["NAME"]
doc.to_h       # {"NAME"=>{"KEY"=>"VALUE", "LIST"=>["ITEM1", "ITEM2"]}}
doc.to_json    # '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}'
```

### Tablatal

```ruby
require 'nodaire/tablatal'

doc = Nodaire::Tablatal.parse! <<~TBTL
  NAME    AGE   COLOR
  Erica   12    Opal
  Alex    23    Cyan
  Nike    34    Red
  Ruca    45    Grey
TBTL

doc.valid?    # true
doc.keys      # ["NAME", "AGE", "COLOR"]
doc.to_a.last # {"NAME"=>"Ruca", "AGE"=>"45", "COLOR"=>"Grey"}
doc.to_csv    # "NAME,AGE,COLOR\nErica,12,Opal\nAlex,23,..."
```

## Testing

```
bundle install
bundle exec rake spec
```
