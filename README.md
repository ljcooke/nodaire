# Nodaire

Ruby parsers for text file formats. Work in progress.

## File formats

- [Oscean](https://wiki.xxiivv.com/#oscean) by Devine Lu Linvega

  - [Indental](https://wiki.xxiivv.com/#indental) (planned)

  - [__Tablatal__](https://wiki.xxiivv.com/#tablatal)

## Examples

```ruby
> input = <<~TBTL
  NAME    AGE   COLOR
  Erica   12    Opal
  Alex    23    Cyan
  Nike    34    Red
  Ruca    45    Grey
  TBTL

> Nodaire::Tablatal.parse(input)
# [
#   { name: 'Erica', age: '12', color: 'Opal' },
#   { name: 'Alex',  age: '23', color: 'Cyan' },
#   { name: 'Nike',  age: '34', color: 'Red' },
#   { name: 'Ruca',  age: '45', color: 'Grey' },
# ]

> Nodaire::Tablatal.parse(input, preserve_keys: true)
# [
#   { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
#   { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan' },
#   { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => 'Red' },
#   { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
# ]

> Nodaire::Tablatal.to_csv(input, preserve_keys: true)
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
