#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open-uri'

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nodaire'

FILENAME = 'test/indental_glossary.ndtl'
URL = 'https://wiki.xxiivv.com/scripts/database/glossary.ndtl'

def get_input
  if File.exist?(FILENAME)
    puts "Reading from #{FILENAME}"
    open(FILENAME).read
  else
    puts "Downloading #{URL}"
    open(URL).read.tap do |string|
      open(FILENAME, 'w').write(string)
    end
  end
end

indental = Nodaire::Indental.parse(get_input)

if indental.valid?
  puts 'Valid'
else
  indental.errors.each { |error| $stderr.puts error }
end
