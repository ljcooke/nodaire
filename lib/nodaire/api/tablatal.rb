# frozen_string_literal: true

require 'csv'

require_relative '../parsers/tablatal_parser'

##
# Interface for the Tablatal file format.
#
# Tablatal is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Tablatal
  attr_reader :data, :keys, :errors
  alias_method :to_a, :data

  ##
  # Parse a string in Tablatal format.
  #
  # Ignores or attempts to work around errors.
  #
  def self.parse(string, symbolize_keys: false)
    parser = Parser.new(string, false, symbolize_keys: symbolize_keys)

    new(parser)
  end

  ##
  # Parse a string in Tablatal format.
  #
  # Raises an exception if there are errors.
  #
  def self.parse!(string, symbolize_keys: false)
    parser = Parser.new(string, true, symbolize_keys: symbolize_keys)

    new(parser)
  end

  ##
  # Returns whether the input was parsed without errors.
  #
  def valid?
    @errors.empty?
  end

  ##
  # Return a string in CSV format.
  #
  def to_csv
    CSV.generate do |csv|
      csv << keys
      data.each do |row|
        csv << keys.map { |key| row[key] }
      end
    end
  end

  private

  def initialize(parser)
    @data = parser.data
    @keys = parser.keys
    @errors = parser.errors
  end
end
