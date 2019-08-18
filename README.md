# Nodaire

Ruby parsers for text file formats. Work in progress.

[![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire)
[![Build Status](https://travis-ci.org/slisne/nodaire.svg?branch=master)](https://travis-ci.org/slisne/nodaire)

## File formats

- [Oscean](https://wiki.xxiivv.com/#oscean) file formats by Devine Lu Linvega:

  - [__Indental__](https://wiki.xxiivv.com/#indental) (.ndtl)
  - [__Tablatal__](https://wiki.xxiivv.com/#tablatal) (.tbtl)

## Examples

### Indental

```ruby
> require 'nodaire/indental'

> input = <<~NDTL
  NAME
    KEY : VALUE
    LIST
      ITEM1
      ITEM2
  NDTL

> indental = Nodaire::Indental.parse(input)

> indental.data
# {
#   'NAME' => {
#     'KEY' => 'VALUE',
#     'LIST' => ['ITEM1', 'ITEM2'],
#   },
# }

> indental.valid?
# true

> indental.to_json
# {"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}
```

### Tablatal

```ruby
> require 'nodaire/tablatal'

> input = <<~TBTL
  NAME    AGE   COLOR
  Erica   12    Opal
  Alex    23    Cyan
  Nike    34    Red
  Ruca    45    Grey
  TBTL

> tablatal = Nodaire::Tablatal.parse(input)

> tablatal.data
# [
#   { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
#   { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan' },
#   { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => 'Red' },
#   { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
# ]

> tablatal.valid?
# true

> tablatal.to_csv
# NAME,AGE,COLOR
# Erica,12,Opal
# Alex,23,Cyan
# Nike,34,Red
# Ruca,45,Grey
```

## Testing

```
bundle install
bundle exec rake spec
```
