# Nodaire

Ruby parsers for text file formats. Work in progress.

[![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire)

## File formats

- [Oscean](https://wiki.xxiivv.com/#oscean) file formats by Devine Lu Linvega:
  - [__Indental__](https://wiki.xxiivv.com/#indental) (.ndtl)
  - [__Tablatal__](https://wiki.xxiivv.com/#tablatal) (.tbtl)

## Examples

__Note__: The API below differs from the v0.1.0 gem that is currently published.

### Indental

```ruby
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
#   name: {
#     key: 'VALUE',
#     list: ['ITEM1', 'ITEM2'],
#   },
# }

> indental.valid?
# true

> indental = Nodaire::Indental.parse(input, preserve_keys: true)

> indental.to_json
# {"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}
```

### Tablatal

```ruby
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
#   { name: 'Erica', age: '12', color: 'Opal' },
#   { name: 'Alex',  age: '23', color: 'Cyan' },
#   { name: 'Nike',  age: '34', color: 'Red' },
#   { name: 'Ruca',  age: '45', color: 'Grey' },
# ]

> tablatal.valid?
# true

> tablatal = Nodaire::Tablatal.parse(input, preserve_keys: true)

> tablatal.to_csv
# NAME,AGE,COLOR
# Erica,12,Opal
# Alex,23,Cyan
# Nike,34,Red
# Ruca,45,Grey
```

## Testing

```
bundle install --with test
bundle exec rspec
```
