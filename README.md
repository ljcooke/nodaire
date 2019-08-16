# Nodaire

Ruby parsers for text file formats. Work in progress.

[![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire)

## File formats

- [Oscean](https://wiki.xxiivv.com/#oscean) by Devine Lu Linvega

  - [Indental](https://wiki.xxiivv.com/#indental) (planned)

  - [__Tablatal__](https://wiki.xxiivv.com/#tablatal)

## Examples

__Note__: The API below differs from the v0.1.0 gem that is currently published.

```ruby
> input = <<~TBTL
  NAME    AGE   COLOR
  Erica   12    Opal
  Alex    23    Cyan
  Nike    34    Red
  Ruca    45    Grey
  TBTL

> tablatal = Nodaire::Tablatal.parse(input)
> tablatal.rows
# [
#   { name: 'Erica', age: '12', color: 'Opal' },
#   { name: 'Alex',  age: '23', color: 'Cyan' },
#   { name: 'Nike',  age: '34', color: 'Red' },
#   { name: 'Ruca',  age: '45', color: 'Grey' },
# ]

> tablatal = Nodaire::Tablatal.parse(input, preserve_keys: true)
> tablatal.rows
# [
#   { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
#   { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan' },
#   { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => 'Red' },
#   { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
# ]

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
