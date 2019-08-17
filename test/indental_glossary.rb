#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open-uri'

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nodaire'

FILENAME = 'test/indental_glossary.ndtl'
URL = 'https://wiki.xxiivv.com/scripts/database/glossary.ndtl'

def read_input!
  if File.exist?(FILENAME)
    puts "Reading from #{FILENAME}"
    File.open(FILENAME).read
  else
    puts "Downloading #{URL}"
    URI.parse(URL).open.read.tap do |string|
      File.open(FILENAME, 'w').write(string)
    end
  end
end

indental = Nodaire::Indental.parse(read_input!, preserve_keys: true)

if indental.valid?
  indental.categories.each do |key|
    puts "#{key} (#{indental.data[key].size})"
  end
else
  indental.errors.each { |message| warn message }
end
