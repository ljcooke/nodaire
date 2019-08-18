# frozen_string_literal: true

require 'json'

require_relative '../parsers/indental_parser'

##
# Interface for the Indental file format.
#
# Indental is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Indental
  attr_reader :data, :errors
  alias_method :to_h, :data

  ##
  # Parse a string in Indental format.
  #
  # Ignores or attempts to work around errors.
  #
  def self.parse(string, symbolize_names: false)
    parser = Parser.new(string, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Parse a string in Indental format.
  #
  # Raises an exception if there are errors.
  #
  def self.parse!(string, symbolize_names: false)
    parser = Parser.new(string, true, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Returns an array of categories.
  #
  def categories
    @data.keys.sort
  end

  ##
  # Returns whether the input was parsed without errors.
  #
  def valid?
    @errors.empty?
  end

  ##
  # Return a string in JSON format.
  #
  def to_json(*_args)
    JSON.generate(data)
  end

  private

  def initialize(parser)
    @data = parser.data
    @errors = parser.errors
  end
end
