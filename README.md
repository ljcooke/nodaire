# Nodaire [![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire) [![Build Status](https://travis-ci.org/slisne/nodaire.svg?branch=master)](https://travis-ci.org/slisne/nodaire)

Nodaire is a collection of text file parsers.
It supports Ruby 2.5.0 or greater.

__Note__: This is a new gem, and the interface is not yet stable.
Expect breaking API changes before v1.0.0 is released.

## File formats

Nodaire currently supports the following text file formats:

  - __Indental__ — <https://wiki.xxiivv.com/#indental>
  - __Tablatal__ — <https://wiki.xxiivv.com/#tablatal>

## Install

Install `nodaire` from [RubyGems](https://rubygems.org/gems/nodaire):

```sh
gem install nodaire
```

## Documentation

[Code documentation](https://slisne.github.io/nodaire/) is available.

Keep reading below for examples of how to use Nodaire.

## Usage examples

### Indental

```ruby
require 'nodaire/indental'

doc = Nodaire::Indental.parse! <<~NDTL
  NAME
    KEY : VALUE
    LIST
      ITEM1
      ITEM2
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

## Development

To run the latest source code, check out the
[Git repository](https://github.com/slisne/nodaire):

```sh
git clone https://github.com/slisne/nodaire.git
```

Install the dependencies using Bundler:

```sh
gem install bundler
bundle install
```

Analyse the code and run unit tests using Bundler:

```sh
bundle exec rake rubocop
bundle exec rake spec
```
