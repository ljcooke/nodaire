# frozen_string_literal: true

require 'nodaire/parsers/tablatal_parser'

##
# Interface for the Tablatal file format.
#
# Tablatal is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Tablatal
  ##
  # Parse a string in Tablatal format and return an array of hashes.
  #
  def self.parse(string)
    Parser.new(string).rows
  end

  ##
  # Parse a string in Tablatal format and return a string in CSV format.
  #
  def self.to_csv(string, preserve_keys: false)
    Parser.new(string, preserve_keys: preserve_keys).to_csv
  end
end
