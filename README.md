# Nodaire [![Gem Version](https://badge.fury.io/rb/nodaire.svg)](https://rubygems.org/gems/nodaire) [![Build Status](https://travis-ci.org/slisne/nodaire.svg?branch=master)](https://travis-ci.org/slisne/nodaire)

Nodaire is a collection of text file parsers.
It supports Ruby 2.5.0 or greater.

__Note__: This is a new gem, and the interface is not yet stable.
Expect breaking API changes before v1.0.0 is released.

## File formats

Nodaire supports the following text file formats:

| File format | Documentation and examples | Origin |
|---|---|---|
| __Indental__ | [`Nodaire::Indental`](https://slisne.github.io/nodaire/Nodaire/Indental.html) | https://wiki.xxiivv.com/#indental |
| __Tablatal__ | [`Nodaire::Tablatal`](https://slisne.github.io/nodaire/Nodaire/Tablatal.html) | https://wiki.xxiivv.com/#tablatal |

## Install

Install `nodaire` from [RubyGems](https://rubygems.org/gems/nodaire):

```sh
gem install nodaire
```

## Documentation

[Code documentation](https://slisne.github.io/nodaire/) is available.

Keep reading below for examples of how to use Nodaire.

## Usage example

```ruby
require 'nodaire/indental'

source = <<~NDTL
  NAME
    KEY : VALUE
    LIST
      ITEM1
      ITEM2
NDTL

doc = Nodaire::Indental.parse(source)

doc.valid?
#=> true

doc.categories
#=> ["NAME"]

doc['NAME']['KEY']
#=> "VALUE"

doc.to_h
#=> {"NAME" => {"KEY"=>"VALUE", "LIST"=>["ITEM1", "ITEM2"]}}

doc.to_json
#=> '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}'
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
