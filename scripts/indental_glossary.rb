#!/usr/bin/env ruby
# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nodaire/indental'
require 'open-uri'

TMP_DIR = 'tmp'
FILENAME = "#{TMP_DIR}/indental_glossary.ndtl"
URL = 'https://wiki.xxiivv.com/scripts/database/glossary.ndtl'

def fetch_glossary!
  Dir.mkdir(TMP_DIR) unless Dir.exist?(TMP_DIR)
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

def parse_glossary
  input = fetch_glossary!
  indental = Nodaire::Indental.parse(input)

  unless indental.valid?
    indental.errors.each { |message| warn message }
    return false
  end

  indental.categories.each do |key|
    puts "#{key} (#{indental.data[key].size})"
  end

  true
end

success = parse_glossary
exit(success ? 0 : 1)
