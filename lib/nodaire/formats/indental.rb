# frozen_string_literal: true

require 'csv'

require_relative '../parsers/indental_parser'

##
# Interface for the Indental file format.
#
# Indental is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Indental
  attr_reader :data
  alias_method :to_h, :data

  ##
  # Parse a string in Indental format.
  #
  def self.parse(string)
    data = Parser.new(string)

    new(data)
  end

  private

  def initialize(data)
    @data = data
  end
end
