# frozen_string_literal: true

require 'csv'

require_relative '../parsers/tablatal_parser'

##
# Interface for the Tablatal file format.
#
# Tablatal is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Tablatal
  attr_reader :rows, :keys
  alias_method :to_a, :rows

  ##
  # Parse a string in Tablatal format.
  #
  def self.parse(string, preserve_keys: false)
    parser = Parser.new(string, preserve_keys: preserve_keys)

    new(parser.rows, parser.keys)
  end

  ##
  # Parse a string in Tablatal format and return a string in CSV format.
  #
  def to_csv
    CSV.generate do |csv|
      csv << keys
      rows.each do |row|
        csv << keys.map { |key| row[key] }
      end
    end
  end

  private

  def initialize(rows, keys)
    @rows = rows
    @keys = keys
  end
end
