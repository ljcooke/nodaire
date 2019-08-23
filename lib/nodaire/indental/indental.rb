# frozen_string_literal: true

require 'json'

require_relative 'parser'

##
# Interface for documents in _Indental_ format.
#
# _Indental_ is a 'dictionary-type database format' by Devine Lu Linvega.
# See: https://wiki.xxiivv.com/#indental
#
#   require 'nodaire/indental'
#
#   doc = Nodaire::Indental.parse! <<~NDTL
#     NAME
#       KEY : VALUE
#       LIST
#         ITEM1
#         ITEM2
#   NDTL
#
#   doc.valid?     # true
#   doc.categories # ["NAME"]
#   doc.to_h       # {"NAME"=>{"KEY"=>"VALUE", "LIST"=>["ITEM1", "ITEM2"]}}
#   doc.to_json    # '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}'
#
# @since 0.2.0
#
class Nodaire::Indental
  include Enumerable

  # A hash containing the data parsed from the source.
  # @deprecated Use +to_h+.
  # @return [Hash]
  attr_reader :data
  # An array of category names.
  # @since 0.3.0
  # @return [Array<String>]
  attr_reader :categories
  # An array of error messages.
  # @return [Array<String>]
  attr_reader :errors

  ##
  # Parse the document +source+.
  #
  # @param [String] source The document source to parse.
  # @param [Boolean] symbolize_names
  #   If true, normalize category and key names and convert them to
  #   lowercase symbols.
  #
  # @return [Indental]
  #
  def self.parse(source, symbolize_names: false)
    parser = Parser.new(source, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Parse the document +source+, raising an exception if a parser error occurs.
  #
  # @param [String] source The document source to parse.
  # @param [boolean] symbolize_names
  #   If true, normalize category and key names and convert them to
  #   lowercase symbols.
  #
  # @raise [ParserError]
  # @return [Indental]
  #
  def self.parse!(source, symbolize_names: false)
    parser = Parser.new(source, true, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # A boolean indicating whether the source was parsed without errors.
  #
  # @return [Boolean]
  #
  def valid?
    @errors.empty?
  end

  ##
  # Convert the document to a hash.
  #
  # @return [Hash]
  #
  def to_h(*args)
    @data.to_h(*args)
  end

  ##
  # Convert the document to JSON.
  #
  # @return [String]
  #
  def to_json(*args)
    @data.to_json(*args)
  end

  # Enumerable
  # @private
  def each(&block)
    @data.each(&block)
  end

  private

  def initialize(parser)
    @data = parser.data
    @errors = parser.errors

    @categories = data.keys
  end
end
