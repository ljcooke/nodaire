# frozen_string_literal: true

require_relative 'base'

module Nodaire
  ##
  # Normalize the whitespace in a string.
  #
  # This strips the string and replaces each sequence of whitespace with
  # a single space.
  #
  # @param [String] string
  #
  # @since 0.4.0
  # @return [String]
  #
  def self.squeeze(string)
    (string || '').gsub(/\s+/, ' ').strip
  end

  ##
  # Convert a string into a normalized symbol.
  #
  # This converts to lower case and replaces each sequence of non-alphanumeric
  # characters with an underscore.
  #
  # @param [String] string
  #
  # @since 0.4.0
  # @return [Symbol]
  #
  def self.symbolize(string)
    squeeze(string).downcase.gsub(/[^a-z0-9]+/, '_').to_sym
  end
end
